CLASS ltcl_lock_material DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'LOCK-TEST-01'.
    CONSTANTS c_other TYPE mard-matnr VALUE 'LOCK-TEST-02'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    DATA mo_cut TYPE REF TO zif_allocation_lock.

    METHODS setup.
    METHODS teardown.

    METHODS free_material_can_be_taken FOR TESTING RAISING cx_static_check.
    METHODS second_claim_is_refused FOR TESTING RAISING cx_static_check.
    METHODS released_material_is_free FOR TESTING RAISING cx_static_check.
    METHODS other_material_is_unaffected FOR TESTING RAISING cx_static_check.
    METHODS other_plant_is_unaffected FOR TESTING RAISING cx_static_check.
    METHODS releasing_twice_is_harmless FOR TESTING RAISING cx_static_check.
    METHODS the_lock_is_waited_for FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_lock_material IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_lock_material( ).
  ENDMETHOD.

  METHOD teardown.

    mo_cut->release(
      iv_matnr = c_matnr
      iv_werks = c_werks ).
    mo_cut->release(
      iv_matnr = c_other
      iv_werks = c_werks ).
    mo_cut->release(
      iv_matnr = c_matnr
      iv_werks = '2000' ).

  ENDMETHOD.

  METHOD the_lock_is_waited_for.

    mo_cut->acquire(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = cl_stub_enqueue=>last_wait( )
      exp = 'X'
      msg = 'a job must not give up on every material somebody is looking at' ).

  ENDMETHOD.

  METHOD free_material_can_be_taken.

    mo_cut->acquire(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD second_claim_is_refused.

    mo_cut->acquire(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    TRY.
        mo_cut->acquire(
          iv_matnr = c_matnr
          iv_werks = c_werks ).
        cl_abap_unit_assert=>fail( 'two runs would both give away the same stock' ).
      CATCH zcx_allocation.
    ENDTRY.

  ENDMETHOD.

  METHOD released_material_is_free.

    mo_cut->acquire(
      iv_matnr = c_matnr
      iv_werks = c_werks ).
    mo_cut->release(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    mo_cut->acquire(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD other_material_is_unaffected.

    mo_cut->acquire(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    mo_cut->acquire(
      iv_matnr = c_other
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD other_plant_is_unaffected.

    mo_cut->acquire(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    mo_cut->acquire(
      iv_matnr = c_matnr
      iv_werks = '2000' ).

  ENDMETHOD.

  METHOD releasing_twice_is_harmless.

    mo_cut->acquire(
      iv_matnr = c_matnr
      iv_werks = c_werks ).
    mo_cut->release(
      iv_matnr = c_matnr
      iv_werks = c_werks ).
    mo_cut->release(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

ENDCLASS.
