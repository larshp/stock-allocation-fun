CLASS zcl_stock_source_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
  PRIVATE SECTION.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_stock_source_sap IMPLEMENTATION.
  METHOD zif_stock_source~get_available.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL.
      raise_error( iv_message = 'Stock read scope is incomplete' ).
    ENDIF.
    IF iv_batch IS INITIAL.
      SELECT SINGLE labst
        FROM mard
        INTO @rs_available-quantity
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location.
    ELSE.
      SELECT SINGLE clabs
        FROM mchb
        INTO @rs_available-quantity
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND charg = @iv_batch.
    ENDIF.
    IF sy-subrc <> 0.
      CLEAR rs_available-quantity.
    ELSEIF iv_batch IS NOT INITIAL.
      rs_available-batch_found = abap_true.
    ENDIF.
    IF rs_available-quantity < 0.
      raise_error( iv_message = 'Stock quantity is invalid' ).
    ENDIF.
    SELECT SINGLE meins, xchpf
      FROM mara
      INTO (@rs_available-unit, @rs_available-batch_managed)
      WHERE matnr = @iv_material.
    IF sy-subrc <> 0.
      CLEAR: rs_available-unit,
             rs_available-material_found,
             rs_available-batch_managed.
    ELSE.
      rs_available-material_found = abap_true.
      IF rs_available-unit IS INITIAL.
        raise_error( iv_message = 'Material base unit is missing' ).
      ENDIF.
    ENDIF.
    IF iv_batch IS NOT INITIAL.
      SELECT SINGLE vfdat, zustd
        FROM mcha
        INTO (@rs_available-batch_expiration_date,
              @rs_available-batch_restricted)
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND charg = @iv_batch.
      IF sy-subrc <> 0.
        CLEAR: rs_available-batch_expiration_date,
               rs_available-batch_restricted.
        IF rs_available-batch_managed = abap_true.
          raise_error( iv_message = 'Batch master data is missing' ).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
