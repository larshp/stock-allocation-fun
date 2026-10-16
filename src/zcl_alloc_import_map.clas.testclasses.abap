CLASS ltcl_alloc_import_map DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_import_map.

    METHODS setup.

    METHODS maps_known_keys FOR TESTING.
    METHODS uses_default    FOR TESTING.
    METHODS keeps_targets   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_import_map IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_import_map( ).
  ENDMETHOD.

  METHOD maps_known_keys.
    DATA lt_source TYPE zcl_alloc_import_map=>ty_source_tt.
    DATA lt_rules  TYPE zcl_alloc_import_map=>ty_rule_tt.
    DATA lt_result TYPE zcl_alloc_import_map=>ty_source_tt.

    APPEND VALUE #( key = 'WERKS' value = '1000' ) TO lt_source.
    APPEND VALUE #( source_key = 'WERKS' target = 'PLANT' ) TO lt_rules.

    lt_result = mo_cut->map( it_source = lt_source it_rules = lt_rules ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-key exp = 'PLANT' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-value exp = '1000' ).
  ENDMETHOD.

  METHOD uses_default.
    DATA lt_source TYPE zcl_alloc_import_map=>ty_source_tt.
    DATA lt_rules  TYPE zcl_alloc_import_map=>ty_rule_tt.
    DATA lt_result TYPE zcl_alloc_import_map=>ty_source_tt.

    APPEND VALUE #( source_key = 'MISSING' target = 'LGORT' default = '0001' ) TO lt_rules.

    lt_result = mo_cut->map( it_source = lt_source it_rules = lt_rules ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-value exp = '0001' ).
  ENDMETHOD.

  METHOD keeps_targets.
    DATA lt_source TYPE zcl_alloc_import_map=>ty_source_tt.
    DATA lt_rules  TYPE zcl_alloc_import_map=>ty_rule_tt.
    DATA lt_result TYPE zcl_alloc_import_map=>ty_source_tt.

    APPEND VALUE #( key = 'A' value = '1' ) TO lt_source.
    APPEND VALUE #( key = 'B' value = '2' ) TO lt_source.
    APPEND VALUE #( source_key = 'A' target = 'X' ) TO lt_rules.
    APPEND VALUE #( source_key = 'B' target = 'Y' ) TO lt_rules.

    lt_result = mo_cut->map( it_source = lt_source it_rules = lt_rules ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-key exp = 'Y' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-value exp = '2' ).
  ENDMETHOD.

ENDCLASS.
