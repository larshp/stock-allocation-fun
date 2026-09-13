CLASS ltcl_alloc_bdc_build DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bdc_build.

    METHODS setup.

    METHODS input
      IMPORTING
        it_rows       TYPE zcl_alloc_bdc_build=>ty_row_tt
        iv_field      TYPE c
        iv_value      TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_bdc_build=>ty_input.

    METHODS adds_row    FOR TESTING.
    METHODS skips_empty FOR TESTING.
    METHODS keeps_rows  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_bdc_build IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bdc_build( ).
  ENDMETHOD.

  METHOD input.
    rs_row-rows = it_rows.
    rs_row-program = 'SAPLZALLOC'.
    rs_row-dynpro = '0100'.
    rs_row-field = iv_field.
    rs_row-value = iv_value.
  ENDMETHOD.

  METHOD adds_row.
    DATA lt_rows TYPE zcl_alloc_bdc_build=>ty_row_tt.

    DATA(lt_new) = mo_cut->add( input( it_rows  = lt_rows
                                       iv_field = 'MATNR'
                                       iv_value = 'MAT-1' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_new ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_new[ 1 ]-field exp = 'MATNR' ).
  ENDMETHOD.

  METHOD skips_empty.
    DATA lt_rows TYPE zcl_alloc_bdc_build=>ty_row_tt.

    DATA(lt_new) = mo_cut->add( input( it_rows  = lt_rows
                                       iv_field = 'MATNR'
                                       iv_value = '' ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_new ).
  ENDMETHOD.

  METHOD keeps_rows.
    DATA lt_rows TYPE zcl_alloc_bdc_build=>ty_row_tt.

    DATA(lt_first) = mo_cut->add( input( it_rows  = lt_rows
                                         iv_field = 'MATNR'
                                         iv_value = 'MAT-1' ) ).

    DATA(lt_second) = mo_cut->add( input( it_rows  = lt_first
                                          iv_field = 'MENGE'
                                          iv_value = '5' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_second ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_second[ 2 ]-value exp = '5' ).
  ENDMETHOD.

ENDCLASS.
