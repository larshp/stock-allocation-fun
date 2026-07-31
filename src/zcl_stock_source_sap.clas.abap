CLASS zcl_stock_source_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
ENDCLASS.

CLASS zcl_stock_source_sap IMPLEMENTATION.
  METHOD zif_stock_source~get_available.
    IF iv_batch IS INITIAL.
      SELECT SINGLE labst
        FROM mard
        INTO @rs_available-quantity
        WHERE mandt = @sy-mandt
          AND matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location.
    ELSE.
      SELECT SINGLE clabs
        FROM mchb
        INTO @rs_available-quantity
        WHERE mandt = @sy-mandt
          AND matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND charg = @iv_batch.
    ENDIF.
    IF sy-subrc <> 0.
      CLEAR rs_available-quantity.
    ELSEIF iv_batch IS NOT INITIAL.
      rs_available-batch_found = abap_true.
    ENDIF.
    SELECT SINGLE meins, xchpf
      FROM mara
      INTO (@rs_available-unit, @rs_available-batch_managed)
      WHERE mandt = @sy-mandt
        AND matnr = @iv_material.
    IF sy-subrc <> 0.
      CLEAR: rs_available-unit,
             rs_available-material_found,
             rs_available-batch_managed.
    ELSE.
      rs_available-material_found = abap_true.
    ENDIF.
    IF iv_batch IS NOT INITIAL.
      SELECT SINGLE vfdat, zustd
        FROM mcha
        INTO (@rs_available-batch_expiration_date,
              @rs_available-batch_restricted)
        WHERE mandt = @sy-mandt
          AND matnr = @iv_material
          AND werks = @iv_plant
          AND charg = @iv_batch.
      IF sy-subrc <> 0.
        CLEAR: rs_available-batch_expiration_date,
               rs_available-batch_restricted.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
