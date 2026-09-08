CLASS zcl_stock_lock_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_lock.

    METHODS constructor
      IMPORTING
        io_gateway       TYPE REF TO zif_stock_lock_gateway
        iv_wait_for_lock TYPE abap_bool DEFAULT abap_false.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_plant_key,
        material TYPE zcl_stock_allocator=>ty_material,
        plant    TYPE zcl_stock_allocator=>ty_plant,
      END OF ty_plant_key.
    TYPES ty_plant_keys TYPE SORTED TABLE OF ty_plant_key
      WITH UNIQUE KEY material plant.

    DATA mo_gateway TYPE REF TO zif_stock_lock_gateway.
    DATA mv_wait_for_lock TYPE abap_bool.
    DATA mt_locked_keys TYPE ty_plant_keys.
ENDCLASS.

CLASS zcl_stock_lock_sap IMPLEMENTATION.
  METHOD constructor.
    mo_gateway = io_gateway.
    mv_wait_for_lock = iv_wait_for_lock.
  ENDMETHOD.

  METHOD zif_stock_lock~acquire.
    IF mv_wait_for_lock <> abap_false AND mv_wait_for_lock <> abap_true.
      rs_result-acquired = abap_false.
      rs_result-message = 'Stock lock wait flag must be X or blank'.
      RETURN.
    ENDIF.

    IF mo_gateway IS NOT BOUND.
      rs_result-acquired = abap_false.
      rs_result-message = 'Stock lock gateway is required'.
      RETURN.
    ENDIF.

    IF mt_locked_keys IS NOT INITIAL.
      rs_result-acquired = abap_false.
      rs_result-message = 'Stock locks are already held'.
      RETURN.
    ENDIF.

    DATA lt_requested_keys TYPE ty_plant_keys.

    LOOP AT it_allocations INTO DATA(ls_allocation)
      WHERE allocated_qty > 0.
      IF ls_allocation-material IS INITIAL
          OR ls_allocation-plant IS INITIAL
          OR zcl_allocation_persistence=>quantity_is_persistable(
            ls_allocation-allocated_qty ) = abap_false.
        rs_result-acquired = abap_false.
        rs_result-message = 'Stock lock allocation is invalid'.
        RETURN.
      ENDIF.

      INSERT VALUE #(
        material = ls_allocation-material
        plant    = ls_allocation-plant )
        INTO TABLE lt_requested_keys.
    ENDLOOP.

    LOOP AT lt_requested_keys INTO DATA(ls_key).
      DATA(ls_lock) = mo_gateway->acquire(
        iv_material      = ls_key-material
        iv_plant         = ls_key-plant
        iv_wait_for_lock = mv_wait_for_lock ).
      IF ls_lock-acquired <> abap_true.
        zif_stock_lock~release( ).
        IF ls_lock-acquired = abap_false.
          rs_result = ls_lock.
          IF rs_result-message IS INITIAL.
            rs_result-message = 'Stock lock acquisition failed'.
          ENDIF.
        ELSE.
          rs_result-acquired = abap_false.
          rs_result-message = 'Stock lock gateway returned invalid state'.
        ENDIF.
        RETURN.
      ENDIF.

      INSERT ls_key INTO TABLE mt_locked_keys.
    ENDLOOP.

    rs_result-acquired = abap_true.
  ENDMETHOD.

  METHOD zif_stock_lock~release.
    LOOP AT mt_locked_keys INTO DATA(ls_key).
      mo_gateway->release(
        iv_material = ls_key-material
        iv_plant    = ls_key-plant ).
    ENDLOOP.
    CLEAR mt_locked_keys.
  ENDMETHOD.
ENDCLASS.
