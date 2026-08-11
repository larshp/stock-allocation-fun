CLASS zcl_stock_source_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_authority TYPE REF TO zif_source_read_authority OPTIONAL.
    INTERFACES zif_stock_source.
  PRIVATE SECTION.
    DATA mo_authority TYPE REF TO zif_source_read_authority.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_stock_source_sap IMPLEMENTATION.
  METHOD constructor.
    IF io_authority IS BOUND.
      mo_authority = io_authority.
    ELSE.
      CREATE OBJECT mo_authority TYPE zcl_source_read_auth_sap.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_source~get_available.
    DATA lv_stock_deleted TYPE c LENGTH 1.
    DATA lv_material_deleted TYPE c LENGTH 1.
    DATA lv_batch_deleted TYPE c LENGTH 1.

    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL.
      raise_error( iv_message = 'Stock read scope is incomplete' ).
    ENDIF.
    IF mo_authority IS BOUND.
      TRY.
          mo_authority->check_stock( iv_batch = iv_batch ).
        CATCH zcx_stock_allocation INTO DATA(lo_authority_error).
          IF lo_authority_error->message IS INITIAL.
            lo_authority_error->message = 'Stock read authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_authority_error.
      ENDTRY.
    ENDIF.
    IF iv_batch IS INITIAL.
      CLEAR lv_stock_deleted.
      SELECT SINGLE labst, lvorm
        FROM mard

        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location INTO ( @rs_available-quantity, @lv_stock_deleted ).
    ELSE.
      CLEAR lv_stock_deleted.
      SELECT SINGLE clabs, lvorm
        FROM mchb

        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND charg = @iv_batch INTO ( @rs_available-quantity, @lv_stock_deleted ).
    ENDIF.
    IF sy-subrc <> 0.
      CLEAR rs_available-quantity.
    ELSEIF lv_stock_deleted <> abap_true
        AND lv_stock_deleted <> abap_false.
      raise_error( iv_message = 'Stock deletion flag is invalid' ).
    ELSEIF lv_stock_deleted = 'X'.
      raise_error( iv_message = 'Stock record is marked for deletion' ).
    ENDIF.
    IF rs_available-quantity < 0.
      raise_error( iv_message = 'Stock quantity is invalid' ).
    ENDIF.
    SELECT SINGLE meins, xchpf, lvorm
      FROM mara

      WHERE matnr = @iv_material INTO ( @rs_available-unit, @rs_available-batch_managed, @lv_material_deleted ).
    IF sy-subrc <> 0.
      CLEAR: rs_available-unit,
             rs_available-material_found,
             rs_available-batch_managed.
    ELSE.
      IF lv_material_deleted <> abap_true
          AND lv_material_deleted <> abap_false.
        raise_error( iv_message = 'Material deletion flag is invalid' ).
      ENDIF.
      IF lv_material_deleted = 'X'.
        raise_error( iv_message = 'Material is marked for deletion' ).
      ENDIF.
      IF rs_available-batch_managed <> abap_true
          AND rs_available-batch_managed <> abap_false.
        raise_error( iv_message = 'Material batch-management flag is invalid' ).
      ENDIF.
      rs_available-unit = to_upper( rs_available-unit ).
      rs_available-material_found = abap_true.
      IF rs_available-unit IS INITIAL.
        raise_error( iv_message = 'Material base unit is missing' ).
      ENDIF.
    ENDIF.
    IF iv_batch IS NOT INITIAL.
      CLEAR lv_batch_deleted.
      SELECT SINGLE vfdat, zustd, lvorm
        FROM mcha
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND charg = @iv_batch
          INTO ( @rs_available-batch_expiration_date,
                 @rs_available-batch_restricted,
                 @lv_batch_deleted ).
      IF sy-subrc <> 0.
        CLEAR: rs_available-batch_expiration_date,
               rs_available-batch_restricted.
        IF rs_available-batch_managed = abap_true.
          raise_error( iv_message = 'Batch master data is missing' ).
        ENDIF.
      ELSEIF lv_batch_deleted = 'X'.
        raise_error( iv_message = 'Batch master data is marked for deletion' ).
      ELSE.
        IF lv_batch_deleted <> abap_true
            AND lv_batch_deleted <> abap_false.
          raise_error( iv_message = 'Batch deletion flag is invalid' ).
        ENDIF.
        IF rs_available-batch_restricted <> abap_true
            AND rs_available-batch_restricted <> abap_false.
          raise_error( iv_message = 'Batch restriction flag is invalid' ).
        ENDIF.
        rs_available-batch_found = abap_true.
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
