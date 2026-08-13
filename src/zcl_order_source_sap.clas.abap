CLASS zcl_order_source_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_authority TYPE REF TO zif_source_read_authority OPTIONAL.
    INTERFACES zif_order_source.
  PRIVATE SECTION.
    DATA mo_authority TYPE REF TO zif_source_read_authority.
    TYPES:
      BEGIN OF ty_schedule,
        order_id            TYPE c LENGTH 10,
        sales_document_type TYPE zif_stock_allocation=>ty_sales_document_type,
        item_id             TYPE n LENGTH 6,
        schedule_line       TYPE n LENGTH 4,
        order_unit          TYPE c LENGTH 3,
        item_deleted        TYPE c LENGTH 1,
        item_delivery_block TYPE c LENGTH 2,
        delivery_priority   TYPE n LENGTH 2,
        requested_on        TYPE d,
        requested           TYPE p LENGTH 8 DECIMALS 3,
        confirmed           TYPE p LENGTH 8 DECIMALS 3,
    END OF ty_schedule.
    TYPES tt_schedule TYPE STANDARD TABLE OF ty_schedule WITH EMPTY KEY.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_order_source_sap IMPLEMENTATION.
  METHOD constructor.
    IF io_authority IS BOUND.
      mo_authority = io_authority.
    ELSE.
      CREATE OBJECT mo_authority TYPE zcl_source_read_auth_sap.
    ENDIF.
  ENDMETHOD.

  METHOD zif_order_source~get_open_demands.
    DATA lt_schedule TYPE tt_schedule.
    DATA ls_demand TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <ls_schedule> TYPE ty_schedule.

    IF iv_material IS INITIAL OR iv_plant IS INITIAL.
      raise_error( iv_message = 'Order demand scope is incomplete' ).
    ENDIF.
    IF mo_authority IS BOUND.
      TRY.
          mo_authority->check_orders( ).
        CATCH zcx_stock_allocation INTO DATA(lo_authority_error).
          IF lo_authority_error->message IS INITIAL.
            lo_authority_error->message = 'Order read authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_authority_error.
      ENDTRY.
    ENDIF.
    IF ( iv_requested_on_from IS NOT INITIAL
          AND zcl_allocation_date_sap=>is_valid_or_initial(
            iv_requested_on_from ) <> abap_true )
        OR ( iv_requested_on_to IS NOT INITIAL
          AND zcl_allocation_date_sap=>is_valid_or_initial(
            iv_requested_on_to ) <> abap_true )
        OR ( iv_requested_on_from IS NOT INITIAL
        AND iv_requested_on_to IS NOT INITIAL
        AND iv_requested_on_from > iv_requested_on_to ).
      raise_error( iv_message = 'Requested delivery date range is invalid' ).
    ENDIF.
    SELECT item~vbeln AS order_id,
           header~auart AS sales_document_type,
           item~posnr AS item_id,
           schedule~etenr AS schedule_line,
           item~vrkme AS order_unit,
           item~loekz AS item_deleted,
           item~lifsp AS item_delivery_block,
           item~lprio AS delivery_priority,
           schedule~edatu AS requested_on,
           schedule~wmeng AS requested,
           schedule~bmeng AS confirmed
      FROM vbap AS item
      INNER JOIN vbak AS header
        ON header~vbeln = item~vbeln
      INNER JOIN vbep AS schedule
        ON schedule~vbeln = item~vbeln
       AND schedule~posnr = item~posnr

      WHERE item~matnr = @iv_material
        AND item~werks = @iv_plant
        AND item~abgru = ''
        AND schedule~lifsp = ''
        AND header~vbtyp = 'C'
        AND header~lifsk = ''
        AND schedule~edatu >= '00000000'
        AND schedule~edatu <= '99999999'
        AND ( schedule~wmeng > schedule~bmeng
          OR schedule~wmeng < 0
          OR schedule~bmeng < 0 ) INTO TABLE @lt_schedule.
    IF sy-subrc <> 0.
      CLEAR rt_demands.
      RETURN.
    ENDIF.

    LOOP AT lt_schedule ASSIGNING <ls_schedule>.
      IF <ls_schedule>-requested_on IS INITIAL.
        raise_error( iv_message = 'Open demand requested date is missing' ).
      ENDIF.
      IF zcl_allocation_date_sap=>is_valid_or_initial(
           <ls_schedule>-requested_on ) <> abap_true.
        raise_error( iv_message = 'Open demand requested date is invalid' ).
      ENDIF.
      IF <ls_schedule>-item_deleted <> abap_true
          AND <ls_schedule>-item_deleted <> abap_false.
        raise_error( iv_message = 'Order item deletion flag is invalid' ).
      ENDIF.
      IF <ls_schedule>-item_deleted = abap_true.
        CONTINUE.
      ENDIF.
      IF <ls_schedule>-item_delivery_block IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      IF iv_requested_on_from IS NOT INITIAL
          AND <ls_schedule>-requested_on < iv_requested_on_from.
        CONTINUE.
      ENDIF.
      IF iv_requested_on_to IS NOT INITIAL
          AND <ls_schedule>-requested_on > iv_requested_on_to.
        CONTINUE.
      ENDIF.
      IF <ls_schedule>-requested < 0
          OR <ls_schedule>-confirmed < 0.
        raise_error( iv_message = 'Open demand quantity is invalid' ).
      ENDIF.
      IF <ls_schedule>-requested <= <ls_schedule>-confirmed.
        CONTINUE.
      ENDIF.
      CLEAR ls_demand.
      ls_demand-sales_document = <ls_schedule>-order_id.
      ls_demand-sales_document_type =
        to_upper( <ls_schedule>-sales_document_type ).
      ls_demand-sales_item = <ls_schedule>-item_id.
      ls_demand-schedule_line = <ls_schedule>-schedule_line.
      ls_demand-order_unit = to_upper( <ls_schedule>-order_unit ).
      CONCATENATE <ls_schedule>-order_id
                  <ls_schedule>-item_id
                  <ls_schedule>-schedule_line
             INTO ls_demand-order_id.
      ls_demand-requested_on = <ls_schedule>-requested_on.
      IF <ls_schedule>-delivery_priority > 0.
        ls_demand-priority = 100 - <ls_schedule>-delivery_priority.
      ENDIF.
      ls_demand-requested = <ls_schedule>-requested - <ls_schedule>-confirmed.
      IF ls_demand-requested > 0
          AND ls_demand-order_unit IS INITIAL.
        raise_error( iv_message = 'Open demand unit is missing' ).
      ENDIF.
      IF ls_demand-requested > 0
          AND ls_demand-sales_document_type IS INITIAL.
        raise_error( iv_message = 'Sales document type is missing' ).
      ENDIF.
      IF ls_demand-sales_document IS INITIAL
          OR strlen( ls_demand-sales_document ) <> zif_stock_allocation=>c_sap_document_length
          OR ls_demand-sales_document CN '0123456789'
          OR ls_demand-sales_document = '0000000000'
          OR ls_demand-sales_item IS INITIAL
          OR ls_demand-schedule_line IS INITIAL
          OR ls_demand-requested <= 0.
        raise_error( iv_message = 'Open demand record is invalid' ).
      ENDIF.
      APPEND ls_demand TO rt_demands.
    ENDLOOP.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
