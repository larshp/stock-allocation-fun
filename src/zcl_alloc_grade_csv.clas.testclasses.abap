CLASS ltcl_alloc_grade_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_grade_csv.

    METHODS setup.

    METHODS header_and_zero_rows FOR TESTING.
    METHODS counts_one_grade    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_grade_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_grade_csv( ).
  ENDMETHOD.

  METHOD header_and_zero_rows.
    DATA lt_items TYPE zcl_alloc_grade_csv=>ty_item_tt.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'GRADE;COUNT' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'A;0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 7 ]
                                        exp = 'F;0' ).
  ENDMETHOD.

  METHOD counts_one_grade.
    DATA lt_items TYPE zcl_alloc_grade_csv=>ty_item_tt.
    DATA ls_item  TYPE zcl_alloc_grade_csv=>ty_item.

    ls_item-coverage_pct = 100.
    ls_item-has_shortage = abap_false.
    APPEND ls_item TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'A;1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = 'B;0' ).
  ENDMETHOD.

ENDCLASS.
