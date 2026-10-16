CLASS ltcl_alloc_hold_release DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_hold_release.
    DATA mt_hld TYPE zcl_alloc_hold_release=>ty_hold_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_code     TYPE string
        iv_blocking TYPE abap_bool.

    METHODS blocked_by_hold FOR TESTING.
    METHODS free_to_release FOR TESTING.
    METHODS reason_forward  FOR TESTING.
    METHODS lists_blocking  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_hold_release IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_hold_release( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_hold TYPE zcl_alloc_hold_release=>ty_hold.

    ls_hold-code = iv_code.
    ls_hold-blocking = iv_blocking.
    APPEND ls_hold TO mt_hld.
  ENDMETHOD.

  METHOD blocked_by_hold.
    add( iv_code = 'QC' iv_blocking = abap_true ).
    add( iv_code = 'NOTE' iv_blocking = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->can_release( mt_hld ) exp = abap_false ).
  ENDMETHOD.

  METHOD free_to_release.
    add( iv_code = 'NOTE' iv_blocking = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->can_release( mt_hld ) exp = abap_true ).
  ENDMETHOD.

  METHOD reason_forward.
    add( iv_code = 'QC' iv_blocking = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( mt_hld ) exp = 'QC' ).
  ENDMETHOD.

  METHOD lists_blocking.
    DATA lt_blocking TYPE zcl_alloc_hold_release=>ty_hold_tt.

    add( iv_code = 'QC' iv_blocking = abap_true ).
    add( iv_code = 'NOTE' iv_blocking = abap_false ).

    lt_blocking = mo_cut->blocking_holds( mt_hld ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_blocking ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_blocking[ 1 ]-code exp = 'QC' ).
  ENDMETHOD.

ENDCLASS.
