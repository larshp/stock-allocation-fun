CLASS zcl_stock_lock_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_lock.

    METHODS constructor
      IMPORTING
        iv_wait_for_lock TYPE abap_bool DEFAULT abap_false.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_stock_key,
        material         TYPE zcl_stock_allocator=>ty_material,
        plant            TYPE zcl_stock_allocator=>ty_plant,
        storage_location TYPE zcl_stock_allocator=>ty_storage_location,
      END OF ty_stock_key.
    TYPES ty_stock_keys TYPE SORTED TABLE OF ty_stock_key
      WITH UNIQUE KEY material plant storage_location.

    DATA mv_wait_for_lock TYPE abap_bool.
    DATA mt_locked_keys TYPE ty_stock_keys.
ENDCLASS.

CLASS zcl_stock_lock_sap IMPLEMENTATION.
  METHOD constructor.
    mv_wait_for_lock = iv_wait_for_lock.
  ENDMETHOD.

  METHOD zif_stock_lock~acquire.
    DATA lt_requested_keys TYPE ty_stock_keys.

    LOOP AT it_allocations INTO DATA(ls_allocation)
      WHERE allocated_qty > 0.
      INSERT VALUE #(
        material         = ls_allocation-material
        plant            = ls_allocation-plant
        storage_location = ls_allocation-storage_location )
        INTO TABLE lt_requested_keys.
    ENDLOOP.

    LOOP AT lt_requested_keys INTO DATA(ls_key).
      CALL FUNCTION 'ENQUEUE_EZSTOCK_POOL'
        EXPORTING
          matnr          = ls_key-material
          werks          = ls_key-plant
          lgort          = ls_key-storage_location
          _scope         = '3'
          _wait          = mv_wait_for_lock
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
      IF sy-subrc <> 0.
        zif_stock_lock~release( ).
        rs_result-acquired = abap_false.
        rs_result-message = 'Stock pool is locked by another process'.
        RETURN.
      ENDIF.

      INSERT ls_key INTO TABLE mt_locked_keys.
    ENDLOOP.

    rs_result-acquired = abap_true.
  ENDMETHOD.

  METHOD zif_stock_lock~release.
    LOOP AT mt_locked_keys INTO DATA(ls_key).
      CALL FUNCTION 'DEQUEUE_EZSTOCK_POOL'
        EXPORTING
          matnr  = ls_key-material
          werks  = ls_key-plant
          lgort  = ls_key-storage_location
          _scope = '3'.
    ENDLOOP.
    CLEAR mt_locked_keys.
  ENDMETHOD.
ENDCLASS.
