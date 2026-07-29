CLASS zcl_salloc_stock_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_salloc_stock.
ENDCLASS.

CLASS zcl_salloc_stock_sap IMPLEMENTATION.
  METHOD zif_salloc_stock~get_available.
    TRY.
        DATA physical TYPE zif_salloc_types=>ty_quantity.
        DATA confirmed TYPE zif_salloc_types=>ty_quantity.
        DATA reserved TYPE zif_salloc_types=>ty_quantity.

        SELECT SINGLE matnr
          FROM marc
          WHERE matnr = @iv_material
            AND werks = @iv_plant
          INTO @DATA(plant_material).
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_salloc_integration
            EXPORTING
              iv_operation = `GET_AVAILABLE`
              iv_reason = `Material is not extended to plant`.
        ENDIF.

        SELECT SUM( labst )
          FROM mard
          WHERE matnr = @iv_material
            AND werks = @iv_plant
          INTO @physical.

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
          confirmed = confirmed + confirmed_quantity.
        ENDLOOP.

        SELECT SINGLE reserved
          FROM zsalloc_stock
          WHERE matnr = @iv_material
            AND werks = @iv_plant
          INTO @reserved.
        IF sy-subrc <> 0.
          CLEAR reserved.
        ENDIF.

        rv_quantity = physical - confirmed - reserved.
        IF rv_quantity < 0.
          CLEAR rv_quantity.
        ENDIF.
      CATCH cx_sy_open_sql_db INTO DATA(db_error).
        RAISE EXCEPTION TYPE zcx_salloc_integration
          EXPORTING
            iv_operation = `GET_AVAILABLE`
            iv_reason = db_error->get_text( ).
    ENDTRY.
  ENDMETHOD.

  METHOD zif_salloc_stock~reserve.
    IF iv_quantity <= 0.
      RAISE EXCEPTION TYPE zcx_salloc_integration
        EXPORTING
          iv_operation = `RESERVE`
          iv_reason = `Reservation quantity must be positive`.
    ENDIF.

    TRY.
        DATA stock_row TYPE zsalloc_stock.
        DATA physical TYPE zif_salloc_types=>ty_quantity.
        DATA confirmed TYPE zif_salloc_types=>ty_quantity.
        SELECT SUM( labst )
          FROM mard
          WHERE matnr = @iv_material
            AND werks = @iv_plant
          INTO @physical.

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
          confirmed = confirmed + confirmed_quantity.
        ENDLOOP.

        SELECT SINGLE *
          FROM zsalloc_stock
          WHERE matnr = @iv_material
            AND werks = @iv_plant
          INTO @stock_row.
        DATA(row_exists) = xsdbool( sy-subrc = 0 ).

        IF iv_quantity > physical - confirmed - stock_row-reserved.
          RAISE EXCEPTION TYPE zcx_salloc_integration
            EXPORTING
              iv_operation = `RESERVE`
              iv_reason = `Available stock changed before reservation`.
        ENDIF.

        stock_row-mandt = sy-mandt.
        stock_row-matnr = iv_material.
        stock_row-werks = iv_plant.
        DATA(previous_reserved) = stock_row-reserved.
        stock_row-reserved = previous_reserved + iv_quantity.

        IF row_exists = abap_true.
          UPDATE zsalloc_stock
            SET reserved = @stock_row-reserved
            WHERE matnr = @iv_material
              AND werks = @iv_plant
              AND reserved = @previous_reserved.
          IF sy-dbcnt <> 1.
            RAISE EXCEPTION TYPE zcx_salloc_integration
              EXPORTING
                iv_operation = `RESERVE`
                iv_reason = `Concurrent stock allocation detected`.
          ENDIF.
        ELSE.
          INSERT zsalloc_stock FROM @stock_row.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zcx_salloc_integration
              EXPORTING
                iv_operation = `RESERVE`
                iv_reason = `Concurrent stock allocation detected`.
          ENDIF.
        ENDIF.
      CATCH cx_sy_open_sql_db INTO DATA(db_error).
        RAISE EXCEPTION TYPE zcx_salloc_integration
          EXPORTING
            iv_operation = `RESERVE`
            iv_reason = db_error->get_text( ).
    ENDTRY.
  ENDMETHOD.

  METHOD zif_salloc_stock~release.
    IF iv_quantity <= 0.
      RAISE EXCEPTION TYPE zcx_salloc_integration
        EXPORTING
          iv_operation = `RELEASE`
          iv_reason = `Release quantity must be positive`.
    ENDIF.

    TRY.
        SELECT SINGLE reserved
          FROM zsalloc_stock
          WHERE matnr = @iv_material
            AND werks = @iv_plant
          INTO @DATA(previous_reserved).
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_salloc_integration
            EXPORTING
              iv_operation = `RELEASE`
              iv_reason = `Release exceeds reserved stock`.
        ELSEIF previous_reserved < iv_quantity.
          RAISE EXCEPTION TYPE zcx_salloc_integration
            EXPORTING
              iv_operation = `RELEASE`
              iv_reason = `Release exceeds reserved stock`.
        ENDIF.

        DATA(new_reserved) = previous_reserved - iv_quantity.
        UPDATE zsalloc_stock
          SET reserved = @new_reserved
          WHERE matnr = @iv_material
            AND werks = @iv_plant
            AND reserved = @previous_reserved.
        IF sy-dbcnt <> 1.
          RAISE EXCEPTION TYPE zcx_salloc_integration
            EXPORTING
              iv_operation = `RELEASE`
              iv_reason = `Concurrent stock allocation detected`.
        ENDIF.
      CATCH cx_sy_open_sql_db INTO DATA(db_error).
        RAISE EXCEPTION TYPE zcx_salloc_integration
          EXPORTING
            iv_operation = `RELEASE`
            iv_reason = db_error->get_text( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
