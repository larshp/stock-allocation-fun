CLASS ltcl_alloc_repair_cost DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_repair_cost.
    DATA mt_par TYPE zcl_alloc_repair_cost=>ty_part_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_part TYPE string
        iv_cost TYPE i.

    METHODS labour_read  FOR TESTING.
    METHODS labour_guard FOR TESTING.
    METHODS parts_read   FOR TESTING.
    METHODS estimate_sum FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_repair_cost IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_repair_cost( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_part TYPE zcl_alloc_repair_cost=>ty_part.

    ls_part-part = iv_part.
    ls_part-cost = iv_cost.
    APPEND ls_part TO mt_par.
  ENDMETHOD.

  METHOD labour_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->labour_cost( iv_labour_minutes = 90 iv_hourly_rate = 100 )
      exp = 150 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->labour_cost( iv_labour_minutes = 30 iv_hourly_rate = 100 )
      exp = 50 ).
  ENDMETHOD.

  METHOD labour_guard.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->labour_cost( iv_labour_minutes = -5 iv_hourly_rate = 100 )
      exp = 0 ).
  ENDMETHOD.

  METHOD parts_read.
    add( iv_part = 'P1' iv_cost = 50 ).
    add( iv_part = 'P2' iv_cost = 30 ).
    add( iv_part = 'P3' iv_cost = -10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->parts_cost( mt_par ) exp = 80 ).
  ENDMETHOD.

  METHOD estimate_sum.
    add( iv_part = 'P1' iv_cost = 50 ).
    add( iv_part = 'P2' iv_cost = 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->estimate( iv_labour_minutes = 90 iv_hourly_rate = 100
                              it_parts = mt_par )
      exp = 230 ).
  ENDMETHOD.

ENDCLASS.
