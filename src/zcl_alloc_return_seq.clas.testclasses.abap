CLASS ltcl_alloc_return_seq DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_seq.
    DATA mt_pnt TYPE zcl_alloc_return_seq=>ty_point_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id       TYPE string
        iv_distance TYPE i.

    METHODS orders_nearest  FOR TESTING.
    METHODS finds_position  FOR TESTING.
    METHODS missing_position FOR TESTING.
    METHODS sums_distance   FOR TESTING.
    METHODS skips_blank_id  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_seq IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_seq( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_point TYPE zcl_alloc_return_seq=>ty_point.

    ls_point-id = iv_id.
    ls_point-distance = iv_distance.
    APPEND ls_point TO mt_pnt.
  ENDMETHOD.

  METHOD orders_nearest.
    DATA lt_sequence TYPE zcl_alloc_return_seq=>ty_stop_tt.

    add( iv_id = 'A' iv_distance = 5 ).
    add( iv_id = 'B' iv_distance = 3 ).
    add( iv_id = 'C' iv_distance = 8 ).

    lt_sequence = mo_cut->sequence( mt_pnt ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_sequence ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sequence[ 1 ]-id exp = 'B' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sequence[ 1 ]-position exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sequence[ 3 ]-id exp = 'C' ).
  ENDMETHOD.

  METHOD finds_position.
    DATA lt_sequence TYPE zcl_alloc_return_seq=>ty_stop_tt.

    add( iv_id = 'A' iv_distance = 5 ).
    add( iv_id = 'B' iv_distance = 3 ).

    lt_sequence = mo_cut->sequence( mt_pnt ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->position_of( it_sequence = lt_sequence iv_id = 'A' )
      exp = 2 ).
  ENDMETHOD.

  METHOD missing_position.
    DATA lt_sequence TYPE zcl_alloc_return_seq=>ty_stop_tt.

    add( iv_id = 'A' iv_distance = 5 ).

    lt_sequence = mo_cut->sequence( mt_pnt ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->position_of( it_sequence = lt_sequence iv_id = 'Z' )
      exp = 0 ).
  ENDMETHOD.

  METHOD sums_distance.
    DATA lt_sequence TYPE zcl_alloc_return_seq=>ty_stop_tt.

    add( iv_id = 'A' iv_distance = 5 ).
    add( iv_id = 'B' iv_distance = 3 ).
    add( iv_id = 'C' iv_distance = 8 ).

    lt_sequence = mo_cut->sequence( mt_pnt ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->distance( lt_sequence ) exp = 16 ).
  ENDMETHOD.

  METHOD skips_blank_id.
    DATA lt_sequence TYPE zcl_alloc_return_seq=>ty_stop_tt.

    add( iv_id = '' iv_distance = 5 ).
    add( iv_id = 'B' iv_distance = 3 ).

    lt_sequence = mo_cut->sequence( mt_pnt ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_sequence ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sequence[ 1 ]-id exp = 'B' ).
  ENDMETHOD.

ENDCLASS.
