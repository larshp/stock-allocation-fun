CLASS ltcl_alloc_mixed_pallet DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_mixed_pallet.
    DATA mt_vol TYPE zcl_alloc_mixed_pallet=>ty_volume_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_volume TYPE i.

    METHODS fills_first_fit   FOR TESTING.
    METHODS opens_new_pallet  FOR TESTING.
    METHODS oversize_own      FOR TESTING.
    METHODS empty_input       FOR TESTING.
    METHODS zero_volume_skip  FOR TESTING.
    METHODS zero_limit_skip   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_mixed_pallet IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_mixed_pallet( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_volume TYPE zcl_alloc_mixed_pallet=>ty_volume.

    ls_volume-volume = iv_volume.
    APPEND ls_volume TO mt_vol.
  ENDMETHOD.

  METHOD fills_first_fit.
    DATA lt_pallets TYPE zcl_alloc_mixed_pallet=>ty_pallet_tt.

    add( iv_volume = 60 ).
    add( iv_volume = 30 ).
    add( iv_volume = 40 ).

    lt_pallets = mo_cut->build( it_volumes = mt_vol iv_pallet_volume = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pallets ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pallets[ 1 ]-used exp = 90 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pallets[ 1 ]-items exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pallets[ 2 ]-used exp = 40 ).
  ENDMETHOD.

  METHOD opens_new_pallet.
    DATA lt_pallets TYPE zcl_alloc_mixed_pallet=>ty_pallet_tt.

    add( iv_volume = 60 ).
    add( iv_volume = 60 ).

    lt_pallets = mo_cut->build( it_volumes = mt_vol iv_pallet_volume = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pallets ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_pallets[ 2 ]-pallet_no exp = 2 ).
  ENDMETHOD.

  METHOD oversize_own.
    DATA lt_pallets TYPE zcl_alloc_mixed_pallet=>ty_pallet_tt.

    add( iv_volume = 150 ).

    lt_pallets = mo_cut->build( it_volumes = mt_vol iv_pallet_volume = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pallets ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pallets[ 1 ]-used exp = 150 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_pallets TYPE zcl_alloc_mixed_pallet=>ty_pallet_tt.

    lt_pallets = mo_cut->build( it_volumes = mt_vol iv_pallet_volume = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pallets ) exp = 0 ).
  ENDMETHOD.

  METHOD zero_volume_skip.
    DATA lt_pallets TYPE zcl_alloc_mixed_pallet=>ty_pallet_tt.

    add( iv_volume = 0 ).

    lt_pallets = mo_cut->build( it_volumes = mt_vol iv_pallet_volume = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pallets ) exp = 0 ).
  ENDMETHOD.

  METHOD zero_limit_skip.
    DATA lt_pallets TYPE zcl_alloc_mixed_pallet=>ty_pallet_tt.

    add( iv_volume = 10 ).

    lt_pallets = mo_cut->build( it_volumes = mt_vol iv_pallet_volume = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pallets ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
