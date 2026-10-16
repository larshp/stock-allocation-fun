CLASS ltcl_alloc_wave DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_wave.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_count      TYPE i
        iv_size       TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_wave=>ty_input.

    METHODS empty_items   FOR TESTING.
    METHODS waves_of_two  FOR TESTING.
    METHODS single_wave   FOR TESTING.
    METHODS zero_size     FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_wave IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_wave( ).
  ENDMETHOD.

  METHOD input.
    DATA lv_index TYPE i.

    WHILE lv_index < iv_count.
      lv_index = lv_index + 1.
      APPEND '1' TO rs_row-items.
    ENDWHILE.

    rs_row-wave_size = iv_size.
  ENDMETHOD.

  METHOD empty_items.
    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->plan( input( iv_count = 0 iv_size = 2 ) ) ).
  ENDMETHOD.

  METHOD waves_of_two.
    DATA(lt_lines) = mo_cut->plan( input( iv_count = 5 iv_size = 2 ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-wave exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-wave exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]-wave exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 5 ]-wave exp = 3 ).
  ENDMETHOD.

  METHOD single_wave.
    DATA(lt_lines) = mo_cut->plan( input( iv_count = 3 iv_size = 10 ) ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]-wave exp = 1 ).
  ENDMETHOD.

  METHOD zero_size.
    DATA(lt_lines) = mo_cut->plan( input( iv_count = 2 iv_size = 0 ) ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-wave exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-wave exp = 0 ).
  ENDMETHOD.

ENDCLASS.
