CLASS ltcl_alloc_putaway_empty DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_putaway_empty.
    DATA mt_bin TYPE zcl_alloc_putaway_empty=>ty_bin_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_bin  TYPE string
        iv_used TYPE i.

    METHODS first_empty FOR TESTING.
    METHODS skips_used  FOR TESTING.
    METHODS none_empty  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_putaway_empty IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_putaway_empty( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_bin TYPE zcl_alloc_putaway_empty=>ty_bin.

    ls_bin-bin_id = iv_bin.
    ls_bin-used = iv_used.
    APPEND ls_bin TO mt_bin.
  ENDMETHOD.

  METHOD first_empty.
    add( iv_bin = 'A-01' iv_used = 0 ).
    add( iv_bin = 'A-02' iv_used = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_empty( it_bins = mt_bin ) exp = 'A-01' ).
  ENDMETHOD.

  METHOD skips_used.
    add( iv_bin = 'A-01' iv_used = 10 ).
    add( iv_bin = 'A-02' iv_used = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_empty( it_bins = mt_bin ) exp = 'A-02' ).
  ENDMETHOD.

  METHOD none_empty.
    add( iv_bin = 'A-01' iv_used = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_empty( it_bins = mt_bin ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
