CLASS zcl_allocation_lock_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_lock.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_lock_key,
        mandt            TYPE c LENGTH 3,
        material         TYPE zif_stock_allocation=>ty_material,
        plant            TYPE zif_stock_allocation=>ty_plant,
        storage_location TYPE zif_stock_allocation=>ty_storage_loc,
      END OF ty_lock_key.
    METHODS get_varkey
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
      RETURNING
        VALUE(rv_varkey)    TYPE rstable-varkey.
ENDCLASS.

CLASS zcl_allocation_lock_sap IMPLEMENTATION.
  METHOD zif_allocation_lock~acquire.
    DATA(lv_varkey) = get_varkey(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location ).
    CALL FUNCTION 'ENQUEUE_E_TABLE'
      EXPORTING
        tabname        = 'ZSTOCKALLOC'
        varkey         = lv_varkey
        _scope         = '2'
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    rv_acquired = xsdbool( sy-subrc = 0 ).
  ENDMETHOD.

  METHOD zif_allocation_lock~release.
    DATA(lv_varkey) = get_varkey(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location ).
    CALL FUNCTION 'DEQUEUE_E_TABLE'
      EXPORTING
        tabname = 'ZSTOCKALLOC'
        varkey  = lv_varkey.
  ENDMETHOD.

  METHOD get_varkey.
    DATA(ls_key) = VALUE ty_lock_key(
      mandt            = sy-mandt
      material         = iv_material
      plant            = iv_plant
      storage_location = iv_storage_location ).
    rv_varkey = ls_key.
  ENDMETHOD.
ENDCLASS.
