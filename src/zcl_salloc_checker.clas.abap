CLASS zcl_salloc_checker DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_result,
        physical TYPE zif_salloc_types=>ty_quantity,
        confirmed TYPE zif_salloc_types=>ty_quantity,
        reserved TYPE zif_salloc_types=>ty_quantity,
        order_allocated TYPE zif_salloc_types=>ty_quantity,
        ledgers_match TYPE abap_bool,
        commitments_fit TYPE abap_bool,
      END OF ty_result.
    METHODS constructor
      IMPORTING io_authorization TYPE REF TO zif_salloc_authorization.
    METHODS run
      IMPORTING
        iv_material TYPE zif_salloc_types=>ty_material
        iv_plant TYPE zif_salloc_types=>ty_plant
      RETURNING VALUE(rs_result) TYPE ty_result
      RAISING zcx_salloc_invalid zcx_salloc_integration.
  PRIVATE SECTION.
    DATA mo_authorization TYPE REF TO zif_salloc_authorization.
ENDCLASS.

CLASS zcl_salloc_checker IMPLEMENTATION.
  METHOD constructor.
    mo_authorization = io_authorization.
  ENDMETHOD.

  METHOD run.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL.
      RAISE EXCEPTION TYPE zcx_salloc_invalid
        EXPORTING iv_reason = `Material and plant are required`.
    ENDIF.
    mo_authorization->check_authorization(
      iv_plant = iv_plant
      iv_activity = '03' ).

    TRY.
        SELECT SINGLE matnr
          FROM marc
          WHERE matnr = @iv_material
            AND werks = @iv_plant
          INTO @DATA(plant_material).
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_salloc_integration
            EXPORTING
              iv_operation = `CHECK`
              iv_reason = `Material is not extended to plant`.
        ENDIF.

        SELECT SUM( labst )
          FROM mard
          WHERE matnr = @iv_material
            AND werks = @iv_plant
          INTO @rs_result-physical.

        DATA confirmed_quantities TYPE STANDARD TABLE OF
          zif_salloc_types=>ty_quantity WITH EMPTY KEY.
        SELECT s~bmeng
          FROM vbep AS s
          INNER JOIN vbap AS b
            ON b~vbeln = s~vbeln
           AND b~posnr = s~posnr
          INNER JOIN vbak AS h
            ON h~vbeln = b~vbeln
          WHERE b~matnr = @iv_material
            AND b~werks = @iv_plant
            AND b~abgru = @space
            AND h~vbtyp = 'C'
          INTO TABLE @confirmed_quantities.
        LOOP AT confirmed_quantities INTO DATA(confirmed_quantity).
          rs_result-confirmed = rs_result-confirmed + confirmed_quantity.
        ENDLOOP.

        SELECT SINGLE reserved
          FROM zsalloc_stock
          WHERE matnr = @iv_material
            AND werks = @iv_plant
          INTO @rs_result-reserved.
        IF sy-subrc <> 0.
          CLEAR rs_result-reserved.
        ENDIF.

        DATA order_quantities TYPE STANDARD TABLE OF
          zif_salloc_types=>ty_quantity WITH EMPTY KEY.
        SELECT allocated
          FROM zsalloc_order
          WHERE matnr = @iv_material
            AND werks = @iv_plant
          INTO TABLE @order_quantities.
        LOOP AT order_quantities INTO DATA(order_quantity).
          rs_result-order_allocated =
            rs_result-order_allocated + order_quantity.
        ENDLOOP.

        rs_result-ledgers_match = xsdbool(
          rs_result-reserved = rs_result-order_allocated ).
        rs_result-commitments_fit = xsdbool(
          rs_result-confirmed + rs_result-reserved <= rs_result-physical ).
      CATCH cx_sy_open_sql_db INTO DATA(db_error).
        RAISE EXCEPTION TYPE zcx_salloc_integration
          EXPORTING
            iv_operation = `CHECK`
            iv_reason = db_error->get_text( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
