CLASS zcl_unit_converter DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_unit_converter.

    METHODS constructor
      IMPORTING
        io_factor_reader TYPE REF TO zif_unit_factor_reader.

  PRIVATE SECTION.
    TYPES ty_rounded_quantity TYPE p LENGTH 7 DECIMALS 3.
    TYPES ty_factor_integer TYPE p LENGTH 3 DECIMALS 0.
    DATA mo_factor_reader TYPE REF TO zif_unit_factor_reader.

    METHODS factor_is_valid
      IMPORTING
        iv_factor       TYPE zif_unit_factor_reader=>ty_factor_value
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.
ENDCLASS.

CLASS zcl_unit_converter IMPLEMENTATION.
  METHOD constructor.
    mo_factor_reader = io_factor_reader.
  ENDMETHOD.

  METHOD zif_unit_converter~to_base.
    IF iv_material IS INITIAL
        OR iv_source_unit IS INITIAL
        OR iv_base_unit IS INITIAL
        OR iv_quantity <= 0
        OR zcl_allocation_persistence=>quantity_is_persistable(
          iv_quantity ) = abap_false.
      rs_result-message = 'Unit conversion input is invalid'.
      RETURN.
    ENDIF.

    DATA(lv_converted_quantity) = iv_quantity.
    IF iv_source_unit <> iv_base_unit.
      IF mo_factor_reader IS NOT BOUND.
        rs_result-message = 'Unit conversion factor reader is required'.
        RETURN.
      ENDIF.

      DATA(ls_factor) = mo_factor_reader->read(
        iv_material    = iv_material
        iv_source_unit = iv_source_unit ).
      IF ls_factor-is_found <> abap_false
          AND ls_factor-is_found <> abap_true.
        rs_result-message = 'Unit conversion lookup returned invalid state'.
        RETURN.
      ENDIF.
      IF ls_factor-is_found = abap_false.
        IF ls_factor-numerator <> 0 OR ls_factor-denominator <> 0.
          rs_result-message = 'Unit conversion lookup returned invalid state'.
        ELSE.
          rs_result-message =
            'No material-specific unit conversion is maintained'.
        ENDIF.
        RETURN.
      ENDIF.
      IF factor_is_valid( ls_factor-numerator ) = abap_false
          OR factor_is_valid( ls_factor-denominator ) = abap_false.
        rs_result-message = 'Unit conversion factor is invalid'.
        RETURN.
      ENDIF.
      lv_converted_quantity =
        iv_quantity * ls_factor-numerator / ls_factor-denominator.
    ENDIF.

    IF lv_converted_quantity > zcl_stock_allocator=>gc_max_quantity.
      rs_result-message = 'Converted base quantity exceeds supported precision'.
      RETURN.
    ENDIF.

    DATA lv_rounded_quantity TYPE ty_rounded_quantity.
    lv_rounded_quantity = lv_converted_quantity.
    IF lv_rounded_quantity <= 0.
      rs_result-message = 'Converted base quantity is not positive'.
      RETURN.
    ENDIF.

    rs_result-is_success = abap_true.
    rs_result-quantity = lv_rounded_quantity.
  ENDMETHOD.

  METHOD factor_is_valid.
    IF iv_factor <= 0 OR iv_factor > 99999.
      RETURN.
    ENDIF.

    DATA lv_integer TYPE ty_factor_integer.
    lv_integer = iv_factor.
    rv_valid = xsdbool( lv_integer = iv_factor ).
  ENDMETHOD.
ENDCLASS.
