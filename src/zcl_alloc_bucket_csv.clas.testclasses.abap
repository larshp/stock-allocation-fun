CLASS ltcl_alloc_bucket_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bucket_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS two_values  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_bucket_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bucket_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA ls_input TYPE zcl_alloc_bucket_csv=>ty_input.

    DATA(lt_lines) = mo_cut->build( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'VALUE;BUCKET' ).
  ENDMETHOD.

  METHOD two_values.
    DATA ls_input TYPE zcl_alloc_bucket_csv=>ty_input.
    DATA ls_item  TYPE zcl_alloc_bucket_csv=>ty_item.

    ls_item-value = '5'.
    APPEND ls_item TO ls_input-items.
    ls_item-value = '25'.
    APPEND ls_item TO ls_input-items.

    APPEND '10' TO ls_input-boundaries.
    APPEND '20' TO ls_input-boundaries.

    DATA(lt_lines) = mo_cut->build( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '5.000;1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = '25.000;3' ).
  ENDMETHOD.

ENDCLASS.
