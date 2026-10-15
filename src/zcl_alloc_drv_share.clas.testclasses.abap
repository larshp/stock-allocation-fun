CLASS ltcl_alloc_drv_share DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_drv_share.
    DATA mt_values TYPE zcl_alloc_drv_share=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS computes_percent FOR TESTING.
    METHODS computes_share   FOR TESTING.
    METHODS picks_largest    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_drv_share IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_drv_share( ).

    add( iv_value = 100 ).
    add( iv_value = 200 ).
    add( iv_value = 100 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_values.
  ENDMETHOD.

  METHOD computes_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_part = 100 iv_whole = 400 )
      exp = 25 ).
  ENDMETHOD.

  METHOD computes_share.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share( it_values = mt_values iv_index = 1 )
      exp = 25 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share( it_values = mt_values iv_index = 2 )
      exp = 50 ).
  ENDMETHOD.

  METHOD picks_largest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest( mt_values ) exp = 200 ).
  ENDMETHOD.

ENDCLASS.
