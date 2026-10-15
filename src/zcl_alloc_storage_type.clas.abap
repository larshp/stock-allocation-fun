CLASS zcl_alloc_storage_type DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_rule,
             mat_group    TYPE string,
             storage_type TYPE string,
           END OF ty_rule.
    TYPES ty_rule_tt TYPE STANDARD TABLE OF ty_rule WITH DEFAULT KEY.

    METHODS assign
      IMPORTING
        it_rules       TYPE ty_rule_tt
        iv_mat_group   TYPE string
      RETURNING
        VALUE(rv_type) TYPE string.

    METHODS has_rule
      IMPORTING
        it_rules        TYPE ty_rule_tt
        iv_mat_group    TYPE string
      RETURNING
        VALUE(rv_found) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_storage_type IMPLEMENTATION.

  METHOD assign.
    " Rules are evaluated in order and the first match wins, so a specific group
    " can be placed before a catch-all one.
    LOOP AT it_rules INTO DATA(ls_rule).
      IF ls_rule-mat_group = iv_mat_group.
        rv_type = ls_rule-storage_type.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_rule.
    rv_found = xsdbool( assign( it_rules     = it_rules
                                iv_mat_group = iv_mat_group ) IS NOT INITIAL ).
  ENDMETHOD.

ENDCLASS.
