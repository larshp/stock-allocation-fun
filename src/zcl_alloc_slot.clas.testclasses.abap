CLASS ltcl_alloc_slot DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_slot.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_count      TYPE i
        iv_slots      TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_slot=>ty_input.

    METHODS empty_count     FOR TESTING.
    METHODS single_slot     FOR TESTING.
    METHODS two_slots       FOR TESTING.
    METHODS zero_slots      FOR TESTING.
    METHODS exactly_two     FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_slot IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_slot( ).
  ENDMETHOD.

  METHOD input.
    rs_row-count = iv_count.
    rs_row-slots = iv_slots.
  ENDMETHOD.

  METHOD empty_count.
    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->assign( input( iv_count = 0 iv_slots = 2 ) ) ).
  ENDMETHOD.

  METHOD single_slot.
    DATA(lt_lines) = mo_cut->assign( input( iv_count = 3 iv_slots = 1 ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-slot exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]-slot exp = 1 ).
  ENDMETHOD.

  METHOD two_slots.
    DATA(lt_lines) = mo_cut->assign( input( iv_count = 5 iv_slots = 2 ) ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-slot exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-slot exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]-slot exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 5 ]-slot exp = 1 ).
  ENDMETHOD.

  METHOD zero_slots.
    DATA(lt_lines) = mo_cut->assign( input( iv_count = 2 iv_slots = 0 ) ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-slot exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-slot exp = 0 ).
  ENDMETHOD.

  METHOD exactly_two.
    DATA(lt_lines) = mo_cut->assign( input( iv_count = 2 iv_slots = 2 ) ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-slot exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-slot exp = 2 ).
  ENDMETHOD.

ENDCLASS.
