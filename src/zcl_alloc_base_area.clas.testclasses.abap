CLASS ltcl_alloc_base_area DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_base_area.
    DATA mt_area TYPE zcl_alloc_base_area=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_area TYPE i.

    METHODS sums_area  FOR TESTING.
    METHODS computes_share FOR TESTING.
    METHODS sums_totals FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_base_area IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_base_area( ).

    add( iv_area = 100 ).
    add( iv_area = 100 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_area TO mt_area.
  ENDMETHOD.

  METHOD sums_area.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->area( mt_area ) exp = 200 ).
  ENDMETHOD.

  METHOD computes_share.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share( iv_area = 100 iv_total = 200 )
      exp = 50 ).
  ENDMETHOD.

  METHOD sums_totals.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_area ) exp = 200 ).
  ENDMETHOD.

ENDCLASS.
