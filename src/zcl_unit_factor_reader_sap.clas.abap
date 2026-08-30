CLASS zcl_unit_factor_reader_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_unit_factor_reader.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_factor,
        material    TYPE zif_unit_converter=>ty_material,
        source_unit TYPE zif_unit_converter=>ty_unit,
        is_found    TYPE abap_bool,
        numerator   TYPE zif_unit_factor_reader=>ty_factor_value,
        denominator TYPE zif_unit_factor_reader=>ty_factor_value,
      END OF ty_factor.
    TYPES ty_factors TYPE HASHED TABLE OF ty_factor
      WITH UNIQUE KEY material source_unit.

    DATA mt_factors TYPE ty_factors.
ENDCLASS.

CLASS zcl_unit_factor_reader_sap IMPLEMENTATION.
  METHOD zif_unit_factor_reader~read.
    IF iv_material IS INITIAL OR iv_source_unit IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE mt_factors INTO DATA(ls_factor)
      WITH TABLE KEY material = iv_material
                     source_unit = iv_source_unit.
    IF sy-subrc <> 0.
      SELECT SINGLE umrez AS numerator,
                    umren AS denominator
        FROM marm
        WHERE matnr = @iv_material
          AND meinh = @iv_source_unit
        INTO CORRESPONDING FIELDS OF @ls_factor.
      ls_factor-material = iv_material.
      ls_factor-source_unit = iv_source_unit.
      ls_factor-is_found = xsdbool( sy-subrc = 0 ).
      IF ls_factor-is_found = abap_true
          AND ( ls_factor-numerator <= 0
            OR ls_factor-denominator <= 0 ).
        CLEAR: ls_factor-is_found,
               ls_factor-numerator,
               ls_factor-denominator.
      ENDIF.
      INSERT ls_factor INTO TABLE mt_factors.
    ENDIF.

    rs_result = CORRESPONDING #( ls_factor ).
  ENDMETHOD.
ENDCLASS.
