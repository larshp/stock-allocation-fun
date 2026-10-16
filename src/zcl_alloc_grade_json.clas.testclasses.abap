CLASS ltcl_alloc_grade_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_grade_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_item   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_grade_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_grade_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_grade_json=>ty_item_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_items )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_item.
    DATA lt_items TYPE zcl_alloc_grade_json=>ty_item_tt.
    DATA ls_item  TYPE zcl_alloc_grade_json=>ty_item.

    ls_item-coverage_pct = 100.
    ls_item-has_shortage = abap_false.
    APPEND ls_item TO lt_items.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_items )
      exp = '[{"coverage_pct":100,"grade":"A"}]' ).
  ENDMETHOD.

ENDCLASS.
