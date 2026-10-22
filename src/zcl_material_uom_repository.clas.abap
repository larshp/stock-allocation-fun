CLASS zcl_material_uom_repository DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
ENDCLASS.

CLASS zcl_material_uom_repository IMPLEMENTATION.

  METHOD zif_material_uom_repository~get_base_unit.
    SELECT SINGLE meins
      FROM mara
      WHERE matnr = @iv_material
      INTO @rv_base_unit.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    SELECT SINGLE umrez AS numerator,
                  umren AS denominator
      FROM marm
      WHERE matnr = @iv_material
        AND meinh = @iv_alternative_unit
      INTO CORRESPONDING FIELDS OF @rs_ratio.
  ENDMETHOD.

ENDCLASS.
