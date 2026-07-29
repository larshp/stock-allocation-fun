CLASS zcl_sap_uom_rules DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES ty_quantity TYPE p LENGTH 16 DECIMALS 3.
    TYPES:
      BEGIN OF ty_conversion,
        material    TYPE string,
        source_unit TYPE string,
        target_unit TYPE string,
        numerator   TYPE ty_quantity,
        denominator TYPE ty_quantity,
      END OF ty_conversion,
      ty_conversions TYPE STANDARD TABLE OF ty_conversion WITH EMPTY KEY,
      BEGIN OF ty_conversion_result,
        quantity TYPE ty_quantity,
        found    TYPE abap_bool,
      END OF ty_conversion_result.

    CLASS-METHODS convert
      IMPORTING
        material       TYPE string
        quantity       TYPE ty_quantity
        source_unit    TYPE string
        target_unit    TYPE string
        conversions    TYPE ty_conversions
      RETURNING
        VALUE(result)  TYPE ty_conversion_result.
ENDCLASS.

CLASS zcl_sap_uom_rules IMPLEMENTATION.
  METHOD convert.
    IF source_unit = target_unit.
      result-quantity = quantity.
      result-found = abap_true.
      RETURN.
    ENDIF.

    LOOP AT conversions INTO DATA(conversion).
      IF conversion-material = material
          AND conversion-source_unit = source_unit
          AND conversion-target_unit = target_unit
          AND conversion-numerator > 0
          AND conversion-denominator > 0.
        result-quantity = quantity
          * conversion-numerator / conversion-denominator.
        result-found = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT conversions INTO conversion.
      IF conversion-material = material
          AND conversion-source_unit = target_unit
          AND conversion-target_unit = source_unit
          AND conversion-numerator > 0
          AND conversion-denominator > 0.
        result-quantity = quantity
          * conversion-denominator / conversion-numerator.
        result-found = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
