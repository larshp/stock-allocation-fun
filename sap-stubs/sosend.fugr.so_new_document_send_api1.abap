FUNCTION so_new_document_send_api1.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(DOCUMENT_DATA) TYPE  SODOCCHGI1
*"     VALUE(DOCUMENT_TYPE) TYPE  SO_OBJ_TP
*"     VALUE(COMMIT_WORK) TYPE  ABAP_BOOL
*"  TABLES
*"      OBJECT_CONTENT STRUCTURE  SOLISTI1
*"      RECEIVERS STRUCTURE  SOMLRECI1
*"  EXCEPTIONS
*"      TOO_MANY_RECEIVERS
*"      DOCUMENT_NOT_SENT
*"      DOCUMENT_TYPE_NOT_EXIST
*"      OPERATION_NO_AUTHORIZATION
*"----------------------------------------------------------------------

* declared explicitly: an inline DATA() in a function module body is never
* declared in the transpiled output, see ANOMALIES.md
  DATA lt_content   TYPE cl_stub_mail=>ty_content_tab.
  DATA lt_receivers TYPE cl_stub_mail=>ty_receiver_tab.

  IF receivers[] IS INITIAL.
    RAISE document_not_sent.
  ENDIF.

  lt_content   = object_content[].
  lt_receivers = receivers[].

  cl_stub_mail=>send(
    is_document = document_data
    iv_type     = document_type
    iv_commit   = commit_work
    it_content  = lt_content
    it_receiver = lt_receivers ).

ENDFUNCTION.
