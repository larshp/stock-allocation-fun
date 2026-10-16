CLASS ltcl_alloc_act_capacity DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_act_capacity.
    DATA mt_line TYPE zcl_alloc_act_capacity=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name      TYPE string
        iv_used      TYPE i
        iv_available TYPE i.

    METHODS sums_available FOR TESTING.
    METHODS sums_used      FOR TESTING.
    METHODS full_rule      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_act_capacity IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_act_capacity( ).

    add( iv_name = 'A' iv_used = 80 iv_available = 100 ).
    add( iv_name = 'B' iv_used = 50 iv_available = 100 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_act_capacity=>ty_line.

    ls_line-name = iv_name.
    ls_line-used = iv_used.
    ls_line-available = iv_available.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD sums_available.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->available( mt_line ) exp = 200 ).
  ENDMETHOD.

  METHOD sums_used.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->used( mt_line ) exp = 130 ).
  ENDMETHOD.

  METHOD full_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_full( iv_used = 200 iv_available = 200 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_full( iv_used = 130 iv_available = 200 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
