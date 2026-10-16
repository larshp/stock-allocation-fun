CLASS ltcl_alloc_pack_hier DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pack_hier.
    DATA mt_lev TYPE zcl_alloc_pack_hier=>ty_level_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name   TYPE string
        iv_factor TYPE i.

    METHODS product_of_all FOR TESTING.
    METHODS up_to_level   FOR TESTING.
    METHODS up_to_first   FOR TESTING.
    METHODS up_to_past_end FOR TESTING.
    METHODS skips_zero    FOR TESTING.
    METHODS empty_levels  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pack_hier IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pack_hier( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_level TYPE zcl_alloc_pack_hier=>ty_level.

    ls_level-name = iv_name.
    ls_level-factor = iv_factor.
    APPEND ls_level TO mt_lev.
  ENDMETHOD.

  METHOD product_of_all.
    add( iv_name = 'EACH' iv_factor = 10 ).
    add( iv_name = 'CARTON' iv_factor = 5 ).
    add( iv_name = 'PALLET' iv_factor = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_units( it_levels = mt_lev ) exp = 1000 ).
  ENDMETHOD.

  METHOD up_to_level.
    add( iv_name = 'EACH' iv_factor = 10 ).
    add( iv_name = 'CARTON' iv_factor = 5 ).
    add( iv_name = 'PALLET' iv_factor = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->units_up_to( it_levels = mt_lev iv_level = 2 )
      exp = 50 ).
  ENDMETHOD.

  METHOD up_to_first.
    add( iv_name = 'EACH' iv_factor = 10 ).
    add( iv_name = 'CARTON' iv_factor = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->units_up_to( it_levels = mt_lev iv_level = 1 )
      exp = 10 ).
  ENDMETHOD.

  METHOD up_to_past_end.
    add( iv_name = 'EACH' iv_factor = 10 ).
    add( iv_name = 'CARTON' iv_factor = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->units_up_to( it_levels = mt_lev iv_level = 9 )
      exp = 50 ).
  ENDMETHOD.

  METHOD skips_zero.
    add( iv_name = 'EACH' iv_factor = 10 ).
    add( iv_name = 'CARTON' iv_factor = 0 ).
    add( iv_name = 'PALLET' iv_factor = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_units( it_levels = mt_lev ) exp = 200 ).
  ENDMETHOD.

  METHOD empty_levels.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_units( it_levels = mt_lev ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
