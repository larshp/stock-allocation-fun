INTERFACE zif_material_uom_repository PUBLIC.

  TYPES:
    BEGIN OF ty_alt_unit_ratio,
      numerator   TYPE marm-umrez,
      denominator TYPE marm-umren,
    END OF ty_alt_unit_ratio.

  METHODS get_base_unit
    IMPORTING
      iv_material         TYPE mard-matnr
    RETURNING
      VALUE(rv_base_unit) TYPE mara-meins.

  METHODS get_alt_unit_ratio
    IMPORTING
      iv_material         TYPE mard-matnr
      iv_alternative_unit TYPE marm-meinh
    RETURNING
      VALUE(rs_ratio)     TYPE ty_alt_unit_ratio.

ENDINTERFACE.
