CLASS ltcl_mail_sender DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_to TYPE string VALUE `planner@example.org`.

    DATA mo_cut TYPE REF TO zif_mail_sender.

    METHODS setup.
    METHODS teardown.

    METHODS the_lines_are_the_document FOR TESTING RAISING cx_static_check.
    METHODS the_subject_is_carried FOR TESTING RAISING cx_static_check.
    METHODS the_address_is_a_receiver FOR TESTING RAISING cx_static_check.
    METHODS nobody_to_send_to_sends_none FOR TESTING RAISING cx_static_check.
    METHODS it_commits_itself FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_mail_sender IMPLEMENTATION.

  METHOD setup.
    cl_stub_mail=>forget( ).
    mo_cut = NEW zcl_mail_sender( ).
  ENDMETHOD.

  METHOD teardown.
    cl_stub_mail=>forget( ).
  ENDMETHOD.

  METHOD the_lines_are_the_document.

    mo_cut->send(
      iv_to      = c_to
      iv_subject = `What is short`
      it_line    = VALUE #( ( `first line` ) ( `second line` ) ) ).

    DATA(lt_sent) = cl_stub_mail=>sent( ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_sent )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_sent[ 1 ]-content )
      exp = 2
      msg = 'a list that arrives with half its lines is worse than none' ).

  ENDMETHOD.

  METHOD the_subject_is_carried.

    mo_cut->send(
      iv_to      = c_to
      iv_subject = `What is short in 1000`
      it_line    = VALUE #( ( `a line` ) ) ).

    " assigned first: the parser cannot read an index on a method call, see
    " ANOMALIES.md
    DATA(lt_sent) = cl_stub_mail=>sent( ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_sent[ 1 ]-subject
      exp = '*What is short in 1000*'
      msg = 'a mail nobody can tell apart in an inbox is a mail nobody opens' ).

  ENDMETHOD.

  METHOD the_address_is_a_receiver.

    mo_cut->send(
      iv_to      = c_to
      iv_subject = `Anything`
      it_line    = VALUE #( ( `a line` ) ) ).

    DATA(lt_sent)     = cl_stub_mail=>sent( ).
    DATA(lt_receiver) = lt_sent[ 1 ]-receiver.

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_receiver )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_receiver[ 1 ]-rec_type
      exp = zcl_mail_sender=>c_internet
      msg = 'an address outside the system is not a SAP user name' ).

  ENDMETHOD.

  METHOD nobody_to_send_to_sends_none.

    mo_cut->send(
      iv_to      = ``
      iv_subject = `Anything`
      it_line    = VALUE #( ( `a line` ) ) ).

    cl_abap_unit_assert=>assert_initial(
      act = cl_stub_mail=>sent( )
      msg = 'a report run without an address is a report somebody is watching' ).

  ENDMETHOD.

  METHOD it_commits_itself.

    mo_cut->send(
      iv_to      = c_to
      iv_subject = `Anything`
      it_line    = VALUE #( ( `a line` ) ) ).

    " a document queued and not committed never leaves, and there is nothing
    " else in this unit of work to lose by committing it
    DATA(lt_sent) = cl_stub_mail=>sent( ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_sent[ 1 ]-commit
      exp = abap_true ).

  ENDMETHOD.

ENDCLASS.
