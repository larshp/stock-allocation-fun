CLASS ltcl_alloc_putaway_open DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_putaway_open.
    DATA mt_bin TYPE zcl_alloc_putaway_open=>ty_bin_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_bin  TYPE string
        iv_free TYPE i.

    METHODS picks_biggest FOR TESTING.
    METHODS skips_full   FOR TESTING.
    METHODS all_full     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_putaway_open IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_putaway_open( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_bin TYPE zcl_alloc_putaway_open=>ty_bin.

    ls_bin-bin_id = iv_bin.
    ls_bin-free = iv_free.
    APPEND ls_bin TO mt_bin.
  ENDMETHOD.

  METHOD picks_biggest.
    add( iv_bin = 'A-01' iv_free = 10 ).
    add( iv_bin = 'A-02' iv_free = 80 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest_free( it_bins = mt_bin ) exp = 'A-02' ).
  ENDMETHOD.

  METHOD skips_full.
    add( iv_bin = 'A-01' iv_free = 0 ).
    add( iv_bin = 'A-02' iv_free = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest_free( it_bins = mt_bin ) exp = 'A-02' ).
  ENDMETHOD.

  METHOD all_full.
    add( iv_bin = 'A-01' iv_free = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest_free( it_bins = mt_bin ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
