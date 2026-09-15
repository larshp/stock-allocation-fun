CLASS ltcl_alloc_lock DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lock.

    METHODS setup.

    METHODS acquire_input
      IMPORTING
        it_locks      TYPE zcl_alloc_lock=>ty_lock_tt
        iv_object     TYPE c
        iv_key        TYPE c
        iv_owner      TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_lock=>ty_acquire.

    METHODS query_input
      IMPORTING
        it_locks      TYPE zcl_alloc_lock=>ty_lock_tt
        iv_object     TYPE c
        iv_key        TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_lock=>ty_query.

    METHODS acquires_lock FOR TESTING.
    METHODS ignores_dup   FOR TESTING.
    METHODS releases_lock FOR TESTING.
    METHODS reports_locked FOR TESTING.
    METHODS reports_free  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_lock IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lock( ).
  ENDMETHOD.

  METHOD acquire_input.
    rs_row-locks = it_locks.
    rs_row-object = iv_object.
    rs_row-key = iv_key.
    rs_row-owner = iv_owner.
  ENDMETHOD.

  METHOD query_input.
    rs_row-locks = it_locks.
    rs_row-object = iv_object.
    rs_row-key = iv_key.
  ENDMETHOD.

  METHOD acquires_lock.
    DATA lt_locks TYPE zcl_alloc_lock=>ty_lock_tt.

    DATA(lt_new) = mo_cut->acquire(
      acquire_input( it_locks  = lt_locks
                     iv_object = 'ZSTOCKRUN'
                     iv_key    = 'R1'
                     iv_owner  = 'USER1' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_new ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_new[ 1 ]-owner exp = 'USER1' ).
  ENDMETHOD.

  METHOD ignores_dup.
    DATA lt_locks TYPE zcl_alloc_lock=>ty_lock_tt.

    DATA(lt_first) = mo_cut->acquire(
      acquire_input( it_locks  = lt_locks
                     iv_object = 'ZSTOCKRUN'
                     iv_key    = 'R1'
                     iv_owner  = 'USER1' ) ).

    DATA(lt_second) = mo_cut->acquire(
      acquire_input( it_locks  = lt_first
                     iv_object = 'ZSTOCKRUN'
                     iv_key    = 'R1'
                     iv_owner  = 'USER2' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_second ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_second[ 1 ]-owner
                                        exp = 'USER1' ).
  ENDMETHOD.

  METHOD releases_lock.
    DATA lt_locks TYPE zcl_alloc_lock=>ty_lock_tt.
    DATA ls_release TYPE zcl_alloc_lock=>ty_release.

    DATA(lt_held) = mo_cut->acquire(
      acquire_input( it_locks  = lt_locks
                     iv_object = 'ZSTOCKRUN'
                     iv_key    = 'R1'
                     iv_owner  = 'USER1' ) ).

    ls_release-locks = lt_held.
    ls_release-object = 'ZSTOCKRUN'.
    ls_release-key = 'R1'.

    DATA(lt_free) = mo_cut->release( ls_release ).

    cl_abap_unit_assert=>assert_initial( act = lt_free ).
  ENDMETHOD.

  METHOD reports_locked.
    DATA lt_locks TYPE zcl_alloc_lock=>ty_lock_tt.

    DATA(lt_held) = mo_cut->acquire(
      acquire_input( it_locks  = lt_locks
                     iv_object = 'ZSTOCKRUN'
                     iv_key    = 'R1'
                     iv_owner  = 'USER1' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_locked( query_input( it_locks  = lt_held
                                            iv_object = 'ZSTOCKRUN'
                                            iv_key    = 'R1' ) )
      exp = abap_true ).
  ENDMETHOD.

  METHOD reports_free.
    DATA lt_locks TYPE zcl_alloc_lock=>ty_lock_tt.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_locked( query_input( it_locks  = lt_locks
                                            iv_object = 'ZSTOCKRUN'
                                            iv_key    = 'R1' ) )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
