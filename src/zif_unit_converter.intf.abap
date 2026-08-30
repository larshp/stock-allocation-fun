INTERFACE zif_unit_converter PUBLIC.
  TYPES ty_material TYPE c LENGTH 40.
  TYPES ty_quantity TYPE decfloat34.
  TYPES ty_unit TYPE c LENGTH 3.

  TYPES:
    BEGIN OF ty_result,
      is_success TYPE abap_bool,
      quantity   TYPE ty_quantity,
      message    TYPE string,
    END OF ty_result.

  METHODS to_base
    IMPORTING
      iv_material      TYPE ty_material
      iv_quantity      TYPE ty_quantity
      iv_source_unit   TYPE ty_unit
      iv_base_unit     TYPE ty_unit
    RETURNING
      VALUE(rs_result) TYPE ty_result.
ENDINTERFACE.
