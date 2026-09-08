INTERFACE zif_unit_factor_reader PUBLIC.
  TYPES ty_factor_value TYPE decfloat34.
  TYPES:
    BEGIN OF ty_result,
      is_found    TYPE abap_bool,
      numerator   TYPE ty_factor_value,
      denominator TYPE ty_factor_value,
    END OF ty_result.

  METHODS read
    IMPORTING
      iv_material      TYPE zif_unit_converter=>ty_material
      iv_source_unit   TYPE zif_unit_converter=>ty_unit
    RETURNING
      VALUE(rs_result) TYPE ty_result.
ENDINTERFACE.
