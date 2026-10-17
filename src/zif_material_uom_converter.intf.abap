INTERFACE zif_material_uom_converter PUBLIC.

  TYPES:
    BEGIN OF ty_result,
      is_successful TYPE abap_bool,
      base_quantity TYPE mard-labst,
      base_unit     TYPE mara-meins,
    END OF ty_result.
  TYPES:
    BEGIN OF ty_unit_ratio,
      is_successful TYPE abap_bool,
      base_unit     TYPE mara-meins,
      numerator     TYPE marm-umrez,
      denominator   TYPE marm-umren,
    END OF ty_unit_ratio.
  TYPES:
    BEGIN OF ty_reverse_result,
      is_successful        TYPE abap_bool,
      alternative_quantity TYPE mard-labst,
      alternative_unit     TYPE mara-meins,
      base_unit            TYPE mara-meins,
    END OF ty_reverse_result.

  METHODS convert_to_base
    IMPORTING
      iv_material      TYPE mard-matnr
      iv_quantity      TYPE mard-labst
      iv_source_unit   TYPE bapisdit-sales_unit
      iv_numerator     TYPE bapisdit-sales_qty1
      iv_denominator   TYPE bapisdit-sales_qty2
    RETURNING
      VALUE(rs_result) TYPE ty_result.

  METHODS convert_material_unit
    IMPORTING
      iv_material      TYPE mard-matnr
      iv_quantity      TYPE mard-labst
      iv_source_unit   TYPE mara-meins
    RETURNING
      VALUE(rs_result) TYPE ty_result.

  METHODS get_material_unit_ratio
    IMPORTING
      iv_material         TYPE mard-matnr
      iv_alternative_unit TYPE mara-meins
    RETURNING
      VALUE(rs_ratio)     TYPE ty_unit_ratio.

  METHODS convert_from_base
    IMPORTING
      iv_material      TYPE mard-matnr
      iv_base_quantity TYPE mard-labst
      iv_target_unit   TYPE mara-meins
    RETURNING
      VALUE(rs_result) TYPE ty_reverse_result.

ENDINTERFACE.
