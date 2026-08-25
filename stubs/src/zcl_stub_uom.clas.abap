"! SAP standard stub: unit of measure conversion (simulates MARM / function
"! module UNIT_OF_MEASURE_SAP_TO_ISO conversions). Sales orders are kept in
"! sales units (VRKME) while stock is managed in base units (MEINS).
CLASS zcl_stub_uom DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_uom_rule,
             matnr TYPE matnr,
             vrkme TYPE vrkme,          " sales unit
             meins TYPE meins,          " base unit
             umrez TYPE umrez,          " numerator:   1 VRKME = UMREZ / UMREN MEINS
             umren TYPE umren,          " denominator
           END OF ty_uom_rule.
    TYPES tt_uom_rules TYPE STANDARD TABLE OF ty_uom_rule WITH DEFAULT KEY.

    "! Convert a quantity from sales unit to base unit.
    "! base_qty = qty * umrez / umren (rounded half up to 3 decimals)
    CLASS-METHODS convert_to_base
      IMPORTING
        iv_matnr       TYPE matnr
        iv_vrkme        TYPE vrkme
        iv_qty          TYPE kwmeng
      RETURNING
        VALUE(rv_base)  TYPE kwmeng.

    "! Test helper: define a conversion rule for a material/unit pair
    CLASS-METHODS add_rule
      IMPORTING
        is_rule TYPE ty_uom_rule.

    "! Test helper: clear all rules
    CLASS-METHODS clear.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA gt_rules TYPE tt_uom_rules.

ENDCLASS.



CLASS zcl_stub_uom IMPLEMENTATION.


  METHOD convert_to_base.
    READ TABLE gt_rules INTO DATA(ls_rule)
      WITH KEY matnr = iv_matnr vrkme = iv_vrkme.
    IF sy-subrc <> 0 OR ls_rule-umren = 0.
      " no rule or invalid denominator: quantity passes through unchanged
      rv_base = iv_qty.
      RETURN.
    ENDIF.

    " base = qty * umrez / umren, rounded half up to 3 decimals
    DATA lv_scaled TYPE p LENGTH 13 DECIMALS 3.
    lv_scaled = ( iv_qty * ls_rule-umrez + ls_rule-umren / 2 )
                DIV ls_rule-umren.
    rv_base = lv_scaled.
  ENDMETHOD.


  METHOD add_rule.
    MODIFY TABLE gt_rules FROM is_rule.
  ENDMETHOD.


  METHOD clear.
    CLEAR gt_rules.
  ENDMETHOD.


ENDCLASS.
