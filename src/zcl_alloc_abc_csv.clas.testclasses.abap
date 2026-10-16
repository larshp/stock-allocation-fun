CLASS ltcl_alloc_abc_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_abc_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_abc_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_abc_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_classes TYPE zcl_alloc_abc=>ty_line_tt.

    DATA(lt_lines) = mo_cut->build( lt_classes ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'MATNR;QUANTITY;SHARE_PCT;CUM_PCT;CLASS' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_classes TYPE zcl_alloc_abc=>ty_line_tt.
    DATA ls_class   TYPE zcl_alloc_abc=>ty_line.

    ls_class-matnr = 'MAT-1'.
    ls_class-quantity = '80'.
    ls_class-share_pct = 80.
    ls_class-cum_pct = 80.
    ls_class-class = 'A'.
    APPEND ls_class TO lt_classes.

    DATA(lt_lines) = mo_cut->build( lt_classes ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'MAT-1;80.000;80;80;A' ).
  ENDMETHOD.

ENDCLASS.
