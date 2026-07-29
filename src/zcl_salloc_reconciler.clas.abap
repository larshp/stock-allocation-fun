CLASS zcl_salloc_reconciler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_service TYPE REF TO zcl_salloc_service
        io_authorization TYPE REF TO zif_salloc_authorization.
    METHODS run
      IMPORTING
        iv_material TYPE zif_salloc_types=>ty_material
        iv_plant TYPE zif_salloc_types=>ty_plant
        iv_simulate TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rv_released) TYPE zif_salloc_types=>ty_quantity
      RAISING
        zcx_salloc_invalid
        zcx_salloc_integration.
  PRIVATE SECTION.
    DATA mo_service TYPE REF TO zcl_salloc_service.
    DATA mo_authorization TYPE REF TO zif_salloc_authorization.
ENDCLASS.

CLASS zcl_salloc_reconciler IMPLEMENTATION.
  METHOD constructor.
    mo_service = io_service.
    mo_authorization = io_authorization.
  ENDMETHOD.

  METHOD run.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL.
      RAISE EXCEPTION TYPE zcx_salloc_invalid
        EXPORTING iv_reason = `Material and plant are required`.
    ENDIF.
    DATA activity TYPE zif_salloc_types=>ty_activity.
    IF iv_simulate = abap_true.
      activity = '03'.
    ELSE.
      activity = '02'.
    ENDIF.
    mo_authorization->check_authorization(
      iv_plant = iv_plant
      iv_activity = activity ).

    TRY.
        DATA allocations TYPE STANDARD TABLE OF zsalloc_order WITH EMPTY KEY.
        SELECT *
          FROM zsalloc_order
          WHERE matnr = @iv_material
            AND werks = @iv_plant
            AND allocated > 0
          INTO TABLE @allocations.

        LOOP AT allocations ASSIGNING FIELD-SYMBOL(<allocation>).
          DATA vbeln TYPE c LENGTH 10.
          DATA posnr TYPE n LENGTH 6.
          DATA etenr TYPE n LENGTH 4.
          vbeln = <allocation>-order_id(10).
          posnr = <allocation>-order_id+10(6).
          etenr = <allocation>-order_id+16(4).

          DATA requested TYPE zif_salloc_types=>ty_quantity.
          DATA confirmed TYPE zif_salloc_types=>ty_quantity.
          SELECT SINGLE s~lmeng, s~bmeng
            FROM vbep AS s
            INNER JOIN vbap AS b
              ON b~vbeln = s~vbeln
             AND b~posnr = s~posnr
            INNER JOIN vbak AS h
              ON h~vbeln = b~vbeln
            WHERE s~vbeln = @vbeln
              AND s~posnr = @posnr
              AND s~etenr = @etenr
              AND b~matnr = @iv_material
              AND b~werks = @iv_plant
              AND b~abgru = @space
              AND h~vbtyp = 'C'
            INTO (@requested, @confirmed).
          IF sy-subrc <> 0.
            CLEAR: requested, confirmed.
          ENDIF.

          DATA(supported) = requested - confirmed.
          IF supported < 0.
            CLEAR supported.
          ENDIF.
          IF <allocation>-allocated > supported.
            DATA(to_release) = <allocation>-allocated - supported.
            IF iv_simulate <> abap_true.
              mo_service->release(
                iv_material = iv_material
                iv_plant = iv_plant
                iv_order_id = <allocation>-order_id
                iv_quantity = to_release ).
            ENDIF.
            rv_released = rv_released + to_release.
          ENDIF.
        ENDLOOP.
      CATCH cx_sy_open_sql_db INTO DATA(db_error).
        RAISE EXCEPTION TYPE zcx_salloc_integration
          EXPORTING
            iv_operation = `RECONCILE`
            iv_reason = db_error->get_text( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
