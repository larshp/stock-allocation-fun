"! SAP standard stub: material substitution (simulates MRP4 substitution
"! settings / material determination). When the requested material cannot
"! cover demand, a substitute material can serve it instead.
CLASS zcl_stub_substitution DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_sub_rule,
             matnr     TYPE matnr,    " original material
             sub_matnr   TYPE matnr,    " substitute material
             priority    TYPE i,        " lower = tried first
           END OF ty_sub_rule.
    TYPES tt_sub_rules TYPE STANDARD TABLE OF ty_sub_rule WITH DEFAULT KEY.

    "! Get substitute materials for iv_matnr ordered by priority
    CLASS-METHODS get_substitutes
      IMPORTING
        iv_matnr          TYPE matnr
      RETURNING
        VALUE(rt_subst)   TYPE tt_sub_rules.

    "! Test helper: define a substitution rule
    CLASS-METHODS add_rule
      IMPORTING
        is_rule TYPE ty_sub_rule.

    "! Test helper: clear all rules
    CLASS-METHODS clear.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA gt_rules TYPE tt_sub_rules.

ENDCLASS.



CLASS zcl_stub_substitution IMPLEMENTATION.


  METHOD get_substitutes.
    LOOP AT gt_rules INTO DATA(ls_rule)
        WHERE matnr = iv_matnr.
      APPEND ls_rule TO rt_subst.
    ENDLOOP.
    SORT rt_subst BY priority ASCENDING.
  ENDMETHOD.


  METHOD add_rule.
    APPEND is_rule TO gt_rules.
  ENDMETHOD.


  METHOD clear.
    CLEAR gt_rules.
  ENDMETHOD.


ENDCLASS.
