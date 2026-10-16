CLASS zcl_alloc_import_map DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_name  TYPE c LENGTH 30.
    TYPES ty_value TYPE c LENGTH 60.

    TYPES: BEGIN OF ty_source,
             key   TYPE ty_name,
             value TYPE ty_value,
           END OF ty_source.
    TYPES ty_source_tt TYPE STANDARD TABLE OF ty_source WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_rule,
             source_key TYPE ty_name,
             target     TYPE ty_name,
             default    TYPE ty_value,
           END OF ty_rule.
    TYPES ty_rule_tt TYPE STANDARD TABLE OF ty_rule WITH DEFAULT KEY.

    METHODS map
      IMPORTING
        it_source        TYPE ty_source_tt
        it_rules         TYPE ty_rule_tt
      RETURNING
        VALUE(rt_result) TYPE ty_source_tt.

ENDCLASS.


CLASS zcl_alloc_import_map IMPLEMENTATION.

  METHOD map.
    DATA ls_rule   TYPE ty_rule.
    DATA ls_source TYPE ty_source.
    DATA lv_value  TYPE ty_value.

    LOOP AT it_rules INTO ls_rule.
      lv_value = ls_rule-default.

      READ TABLE it_source INTO ls_source WITH KEY key = ls_rule-source_key.

      IF sy-subrc = 0 AND ls_source-value IS NOT INITIAL.
        lv_value = ls_source-value.
      ENDIF.

      APPEND VALUE #( key = ls_rule-target value = lv_value ) TO rt_result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
