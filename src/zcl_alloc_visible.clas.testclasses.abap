"! Allows the plants it was told to allow, and counts the asking.
CLASS lcl_authority_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    TYPES ty_werks_tab TYPE STANDARD TABLE OF mard-werks WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        it_allowed TYPE ty_werks_tab.

    METHODS asked
      RETURNING
        VALUE(rv_asked) TYPE i.

  PRIVATE SECTION.
    DATA mt_allowed TYPE ty_werks_tab.
    DATA mv_asked   TYPE i.

ENDCLASS.


CLASS lcl_authority_double IMPLEMENTATION.

  METHOD constructor.
    mt_allowed = it_allowed.
  ENDMETHOD.

  METHOD asked.
    rv_asked = mv_asked.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.

    mv_asked = mv_asked + 1.

    IF NOT line_exists( mt_allowed[ table_line = iv_werks ] ).
      RAISE EXCEPTION NEW zcx_allocation(
        textid   = zcx_allocation=>not_authorised
        mv_werks = |{ iv_werks }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_visible DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_mine   TYPE mard-werks VALUE '1000'.
    CONSTANTS c_theirs TYPE mard-werks VALUE '2000'.

    DATA mo_authority TYPE REF TO lcl_authority_double.
    DATA mo_cut       TYPE REF TO zcl_alloc_visible.

    METHODS wire
      IMPORTING
        it_allowed TYPE lcl_authority_double=>ty_werks_tab.

    METHODS an_allowed_plant_is_seen FOR TESTING RAISING cx_static_check.
    METHODS a_refused_plant_is_not FOR TESTING RAISING cx_static_check.
    METHODS the_answer_is_remembered FOR TESTING RAISING cx_static_check.
    METHODS a_refusal_is_remembered_too FOR TESTING RAISING cx_static_check.
    METHODS each_plant_is_asked_once FOR TESTING RAISING cx_static_check.
    METHODS check_plant_lets_it_through FOR TESTING RAISING cx_static_check.
    METHODS check_plant_refuses FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_alloc_visible IMPLEMENTATION.

  METHOD wire.

    mo_authority = NEW lcl_authority_double( it_allowed ).
    mo_cut       = NEW zcl_alloc_visible( mo_authority ).

  ENDMETHOD.

  METHOD an_allowed_plant_is_seen.

    wire( VALUE #( ( c_mine ) ) ).

    cl_abap_unit_assert=>assert_true( mo_cut->may_see( c_mine ) ).

  ENDMETHOD.

  METHOD a_refused_plant_is_not.

    " a plant the user may not see is a no rather than an exception: the
    " caller is deciding what to leave off a page, not what to refuse
    wire( VALUE #( ( c_mine ) ) ).

    cl_abap_unit_assert=>assert_false( mo_cut->may_see( c_theirs ) ).

  ENDMETHOD.

  METHOD the_answer_is_remembered.

    wire( VALUE #( ( c_mine ) ) ).

    mo_cut->may_see( c_mine ).
    mo_cut->may_see( c_mine ).
    mo_cut->may_see( c_mine ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_authority->asked( )
      exp = 1 ).

  ENDMETHOD.

  METHOD a_refusal_is_remembered_too.

    " the expensive case is the plant the user may not see, because a page
    " that asks about it once per material asks about it most often
    wire( VALUE #( ( c_mine ) ) ).

    cl_abap_unit_assert=>assert_false( mo_cut->may_see( c_theirs ) ).
    cl_abap_unit_assert=>assert_false( mo_cut->may_see( c_theirs ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_authority->asked( )
      exp = 1 ).

  ENDMETHOD.

  METHOD each_plant_is_asked_once.

    wire( VALUE #( ( c_mine ) ) ).

    mo_cut->may_see( c_mine ).
    mo_cut->may_see( c_theirs ).
    mo_cut->may_see( c_mine ).
    mo_cut->may_see( c_theirs ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_authority->asked( )
      exp = 2 ).

  ENDMETHOD.

  METHOD check_plant_lets_it_through.

    wire( VALUE #( ( c_mine ) ) ).

    mo_cut->check_plant( c_mine ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_authority->asked( )
      exp = 1 ).

  ENDMETHOD.

  METHOD check_plant_refuses.

    " the plant a page was called for is refused rather than left out, and
    " with whatever the authority object itself had to say about it
    wire( VALUE #( ( c_mine ) ) ).

    TRY.
        mo_cut->check_plant( c_theirs ).
        cl_abap_unit_assert=>fail( 'a plant the user may not see is refused' ).
      CATCH zcx_allocation INTO DATA(lx_error).
        cl_abap_unit_assert=>assert_char_cp(
          act = lx_error->get_text( )
          exp = '*2000*' ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
