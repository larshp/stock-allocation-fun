CLASS zcl_material_uom_converter DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO zif_material_uom_repository.

    INTERFACES zif_material_uom_converter.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO zif_material_uom_repository.
ENDCLASS.

CLASS zcl_material_uom_converter IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD zif_material_uom_converter~convert_to_base.
    IF iv_material IS INITIAL OR iv_source_unit IS INITIAL.
      RETURN.
    ENDIF.

    rs_result-base_unit = mo_repository->get_base_unit( iv_material ).
    IF rs_result-base_unit IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_source_unit = rs_result-base_unit.
      rs_result-base_quantity = iv_quantity.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    IF iv_numerator <= 0 OR iv_denominator <= 0.
      RETURN.
    ENDIF.

    rs_result-base_quantity = CONV mard-labst(
      CONV decfloat34( iv_quantity )
      * CONV decfloat34( iv_numerator )
      / CONV decfloat34( iv_denominator ) ).
    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD zif_material_uom_converter~convert_material_unit.
    IF iv_material IS INITIAL OR iv_source_unit IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_unit_ratio) =
      zif_material_uom_converter~get_material_unit_ratio(
        iv_material         = iv_material
        iv_alternative_unit = iv_source_unit ).
    rs_result-base_unit = ls_unit_ratio-base_unit.
    IF ls_unit_ratio-is_successful <> abap_true.
      RETURN.
    ENDIF.

    rs_result-base_quantity = CONV mard-labst(
      CONV decfloat34( iv_quantity )
      * CONV decfloat34( ls_unit_ratio-numerator )
      / CONV decfloat34( ls_unit_ratio-denominator ) ).
    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD zif_material_uom_converter~get_material_unit_ratio.
    DATA ls_ratio TYPE zif_material_uom_repository=>ty_alt_unit_ratio.

    IF iv_material IS INITIAL OR iv_alternative_unit IS INITIAL.
      RETURN.
    ENDIF.

    rs_ratio-base_unit = mo_repository->get_base_unit( iv_material ).
    IF rs_ratio-base_unit IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_alternative_unit = rs_ratio-base_unit.
      rs_ratio-numerator = 1.
      rs_ratio-denominator = 1.
      rs_ratio-is_successful = abap_true.
      RETURN.
    ENDIF.

    ls_ratio = mo_repository->get_alt_unit_ratio(
      iv_material         = iv_material
      iv_alternative_unit = iv_alternative_unit ).
    IF ls_ratio-numerator <= 0 OR ls_ratio-denominator <= 0.
      RETURN.
    ENDIF.

    rs_ratio-numerator = ls_ratio-numerator.
    rs_ratio-denominator = ls_ratio-denominator.
    rs_ratio-is_successful = abap_true.
  ENDMETHOD.

  METHOD zif_material_uom_converter~convert_from_base.
    DATA(ls_unit_ratio) =
      zif_material_uom_converter~get_material_unit_ratio(
        iv_material         = iv_material
        iv_alternative_unit = iv_target_unit ).
    rs_result-base_unit = ls_unit_ratio-base_unit.
    rs_result-alternative_unit = iv_target_unit.
    IF ls_unit_ratio-is_successful <> abap_true.
      RETURN.
    ENDIF.

    rs_result-alternative_quantity = CONV mard-labst(
      CONV decfloat34( iv_base_quantity )
      * CONV decfloat34( ls_unit_ratio-denominator )
      / CONV decfloat34( ls_unit_ratio-numerator ) ).
    rs_result-is_successful = abap_true.
  ENDMETHOD.

ENDCLASS.
