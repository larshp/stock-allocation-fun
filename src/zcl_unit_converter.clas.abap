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
    TYPES ty_rounded_quantity TYPE p LENGTH 13 DECIMALS 3.
    DATA mo_factor_reader TYPE REF TO zif_unit_factor_reader.
ENDCLASS.

CLASS zcl_unit_converter IMPLEMENTATION.
  METHOD constructor.
    mo_factor_reader = io_factor_reader.
  ENDMETHOD.

  METHOD zif_unit_converter~to_base.
    DATA(lv_converted_quantity) = iv_quantity.
    IF iv_source_unit <> iv_base_unit.
      DATA(ls_factor) = mo_factor_reader->read(
        iv_material    = iv_material
        iv_source_unit = iv_source_unit ).
      IF ls_factor-is_found <> abap_false
          AND ls_factor-is_found <> abap_true.
        rs_result-message = 'Unit conversion lookup returned invalid state'.
        RETURN.
      ENDIF.
      IF ls_factor-is_found <> abap_true
          OR ls_factor-numerator <= 0
          OR ls_factor-denominator <= 0.
        rs_result-message = 'No material-specific unit conversion is maintained'.
        RETURN.
      ENDIF.
      lv_converted_quantity =
        iv_quantity * ls_factor-numerator / ls_factor-denominator.
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
ENDCLASS.
