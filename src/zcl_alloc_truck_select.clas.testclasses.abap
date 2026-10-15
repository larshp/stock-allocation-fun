CLASS ltcl_alloc_truck_select DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_truck_select.
    DATA mt_tru TYPE zcl_alloc_truck_select=>ty_truck_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_type   TYPE string
        iv_weight TYPE i
        iv_volume TYPE i.

    METHODS smallest_fits   FOR TESTING.
    METHODS none_fits       FOR TESTING.
    METHODS ignores_invalid FOR TESTING.
    METHODS empty_list      FOR TESTING.
    METHODS volume_tiebreak FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_truck_select IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_truck_select( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_truck TYPE zcl_alloc_truck_select=>ty_truck.

    ls_truck-truck_type = iv_type.
    ls_truck-max_weight = iv_weight.
    ls_truck-max_volume = iv_volume.
    APPEND ls_truck TO mt_tru.
  ENDMETHOD.

  METHOD smallest_fits.
    add( iv_type = 'XL' iv_weight = 2000 iv_volume = 200 ).
    add( iv_type = 'S' iv_weight = 1000 iv_volume = 100 ).
    add( iv_type = 'M' iv_weight = 1500 iv_volume = 150 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->select( it_trucks = mt_tru iv_weight = 900
                            iv_volume = 90 )
      exp = 'S' ).
  ENDMETHOD.

  METHOD none_fits.
    add( iv_type = 'S' iv_weight = 1000 iv_volume = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->select( it_trucks = mt_tru iv_weight = 1200
                            iv_volume = 50 )
      exp = '' ).
  ENDMETHOD.

  METHOD ignores_invalid.
    add( iv_type = 'BAD' iv_weight = 0 iv_volume = 0 ).
    add( iv_type = 'OK' iv_weight = 1000 iv_volume = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->select( it_trucks = mt_tru iv_weight = 10
                            iv_volume = 10 )
      exp = 'OK' ).
  ENDMETHOD.

  METHOD empty_list.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->select( it_trucks = mt_tru iv_weight = 10
                            iv_volume = 10 )
      exp = '' ).
  ENDMETHOD.

  METHOD volume_tiebreak.
    add( iv_type = 'BIG' iv_weight = 1000 iv_volume = 200 ).
    add( iv_type = 'SMALL' iv_weight = 1000 iv_volume = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->select( it_trucks = mt_tru iv_weight = 500
                            iv_volume = 50 )
      exp = 'SMALL' ).
  ENDMETHOD.

ENDCLASS.
