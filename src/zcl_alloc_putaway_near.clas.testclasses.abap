CLASS ltcl_alloc_putaway_near DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_putaway_near.
    DATA mt_bin TYPE zcl_alloc_putaway_near=>ty_bin_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_bin  TYPE string
        iv_free TYPE i
        iv_dist TYPE i.

    METHODS picks_nearest FOR TESTING.
    METHODS needs_room    FOR TESTING.
    METHODS none_fit      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_putaway_near IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_putaway_near( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_bin TYPE zcl_alloc_putaway_near=>ty_bin.

    ls_bin-bin_id = iv_bin.
    ls_bin-free = iv_free.
    ls_bin-distance = iv_dist.
    APPEND ls_bin TO mt_bin.
  ENDMETHOD.

  METHOD picks_nearest.
    add( iv_bin = 'A-01' iv_free = 100 iv_dist = 50 ).
    add( iv_bin = 'A-02' iv_free = 100 iv_dist = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->nearest( it_bins = mt_bin iv_qty = 10 ) exp = 'A-02' ).
  ENDMETHOD.

  METHOD needs_room.
    add( iv_bin = 'A-01' iv_free = 5 iv_dist = 1 ).
    add( iv_bin = 'A-02' iv_free = 100 iv_dist = 90 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->nearest( it_bins = mt_bin iv_qty = 10 ) exp = 'A-02' ).
  ENDMETHOD.

  METHOD none_fit.
    add( iv_bin = 'A-01' iv_free = 5 iv_dist = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->nearest( it_bins = mt_bin iv_qty = 10 ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
