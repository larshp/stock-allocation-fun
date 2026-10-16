CLASS zcl_alloc_hazard_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_rule,
             hazard_class  TYPE string,
             storage_class TYPE string,
             allowed       TYPE abap_bool,
           END OF ty_rule.
    TYPES ty_rule_tt TYPE STANDARD TABLE OF ty_rule WITH DEFAULT KEY.

    METHODS allowed
      IMPORTING
        it_rules          TYPE ty_rule_tt
        iv_hazard_class   TYPE string
        iv_storage_class  TYPE string
      RETURNING
        VALUE(rv_allowed) TYPE abap_bool.

    METHODS conflict
      IMPORTING
        it_rules           TYPE ty_rule_tt
        iv_hazard_class    TYPE string
        iv_storage_class   TYPE string
      RETURNING
        VALUE(rv_conflict) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_hazard_check IMPLEMENTATION.

  METHOD allowed.
    " The first matching rule decides. Without a rule the pairing is not allowed,
    " which is the safe default for hazardous goods.
    LOOP AT it_rules INTO DATA(ls_rule).
      IF ls_rule-hazard_class = iv_hazard_class
         AND ls_rule-storage_class = iv_storage_class.
        rv_allowed = ls_rule-allowed.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD conflict.
    " A conflict is an explicit rule that forbids the pairing, which is different
    " from simply having no rule at all.
    LOOP AT it_rules INTO DATA(ls_rule).
      IF ls_rule-hazard_class = iv_hazard_class
         AND ls_rule-storage_class = iv_storage_class.
        rv_conflict = xsdbool( ls_rule-allowed = abap_false ).
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
