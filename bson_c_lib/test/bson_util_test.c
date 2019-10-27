#include <check.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <float.h>
#include "bson_util.h"

START_TEST(read_int32_le_zero)
{
  uint8_t buf[4] = {0, 0, 0, 0};
  uint8_t *p = buf;
  int32_t ret = read_int32_le(&p);
  ck_assert_ptr_eq(p, buf + 4);
  ck_assert_int_eq(ret, 0);
}
END_TEST

START_TEST(read_int32_le_positive)
{
  uint8_t buf[5] = {0x9C, 0x92, 0xDC, 0x5F, 0x00};
  uint8_t *p = buf;
  int32_t ret = read_int32_le(&p);
  ck_assert_ptr_eq(p, buf + 4);
  ck_assert_int_eq(ret, 0x5FDC929C);
}
END_TEST

START_TEST(read_int32_le_negative)
{
  uint8_t buf[4] = {0x60, 0xD1, 0x03, 0xAC};
  int32_t expected = -(int32_t)((~((uint32_t)0xAC03D160) + 1)); // = -1409035936
  uint8_t *p = buf;
  int32_t ret = read_int32_le(&p);
  ck_assert_ptr_eq(p, buf + 4);
  ck_assert_int_eq(ret, expected);
}
END_TEST

START_TEST(read_int32_le_positive_max)
{
  uint8_t buf[4] = {0xFF, 0xFF, 0xFF, 0x7F};
  uint8_t *p = buf;
  int32_t ret = read_int32_le(&p);
  ck_assert_ptr_eq(p, buf + 4);
  ck_assert_int_eq(ret, INT32_MAX);
}
END_TEST

START_TEST(read_int32_le_negative_max)
{
  uint8_t buf[4] = {0xFF, 0xFF, 0xFF, 0xFF};
  uint8_t *p = buf;
  int32_t ret = read_int32_le(&p);
  ck_assert_ptr_eq(p, buf + 4);
  ck_assert_int_eq(ret, -1);
}
END_TEST

START_TEST(read_int32_le_negative_min)
{
  uint8_t buf[4] = {0, 0, 0, 0x80};
  uint8_t *p = buf;
  int32_t ret = read_int32_le(&p);
  ck_assert_ptr_eq(p, buf + 4);
  ck_assert_int_eq(ret, INT32_MIN);
}
END_TEST


START_TEST(read_int64_le_zero)
{
  uint8_t buf[8] = {0, 0, 0, 0, 0, 0, 0, 0};
  uint8_t *p = buf;
  int64_t ret = read_int64_le(&p);
  ck_assert_ptr_eq(p, buf + 8);
  ck_assert_int_eq(ret, 0);
}
END_TEST

START_TEST(read_int64_le_positive)
{
  uint8_t buf[8] = {0x12, 0xA2, 0xBF, 0x82, 0x34, 0xD0, 0x07, 0x73};
  uint8_t *p = buf;
  int64_t ret = read_int64_le(&p);
  ck_assert_ptr_eq(p, buf + 8);
  ck_assert_int_eq(ret, 0x7307D03482BFA212);
}
END_TEST

START_TEST(read_int64_le_negative)
{
  uint8_t buf[8] = {0x34, 0xC9, 0x30, 0x74, 0x22, 0x6F, 0xCA, 0xBD};
  int64_t expected = -(int64_t)((~((uint64_t)0xBDCA6F227430C934) + 1)); // = -4770878661476693708
  uint8_t *p = buf;
  int64_t ret = read_int64_le(&p);
  ck_assert_ptr_eq(p, buf + 8);
  ck_assert_int_eq(ret, expected);
}
END_TEST

START_TEST(read_int64_le_positive_max)
{
  uint8_t buf[8] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F};
  uint8_t *p = buf;
  int64_t ret = read_int64_le(&p);
  ck_assert_ptr_eq(p, buf + 8);
  ck_assert_int_eq(ret, INT64_MAX);
}
END_TEST

START_TEST(read_int64_le_negative_min)
{
  uint8_t buf[8] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
  uint8_t *p = buf;
  int64_t ret = read_int64_le(&p);
  ck_assert_ptr_eq(p, buf + 8);
  ck_assert_int_eq(ret, -1);
}
END_TEST

START_TEST(read_int64_le_negative_max)
{
  uint8_t buf[8] = {0, 0, 0, 0, 0, 0, 0, 0x80};
  uint8_t *p = buf;
  int64_t ret = read_int64_le(&p);
  ck_assert_ptr_eq(p, buf + 8);
  ck_assert_int_eq(ret, INT64_MIN);
}
END_TEST


START_TEST(read_double_le_zero)
{
  uint8_t buf[8] = {0, 0, 0, 0, 0, 0, 0, 0};
  uint8_t *p = buf;
  double ret = read_double_le(&p);
  ck_assert_ptr_eq(p, buf + 8);
  ck_assert(ret == 0.0);
}
END_TEST

START_TEST(read_double_le_positive)
{
  uint8_t buf[9] = {0x9A, 0x99, 0x99, 0x99, 0x19, 0x74, 0x67, 0x40, 0x00};
  uint8_t *p = buf;
  double ret = read_double_le(&p);
  ck_assert_ptr_eq(p, buf + 8);
  ck_assert(ret == 187.628125);
}
END_TEST

START_TEST(read_double_le_negative)
{
  uint8_t buf[8] = {0x0, 0x0, 0x0, 0x0, 0x0, 0xA8, 0x5D, 0xC0};
  uint8_t *p = buf;
  double ret = read_double_le(&p);
  ck_assert_ptr_eq(p, buf + 8);
  ck_assert(ret == -118.625);
}
END_TEST

START_TEST(read_double_le_positive_max)
{
  uint8_t buf[8] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xEF, 0x7F};
  uint8_t *p = buf;
  double ret = read_double_le(&p);
  ck_assert_ptr_eq(p, buf + 8);
  ck_assert(ret == DBL_MAX);
}
END_TEST

START_TEST(read_double_le_positive_min)
{
  uint8_t buf[8] = {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x10, 0x0};
  uint8_t *p = buf;
  double ret = read_double_le(&p);
  ck_assert_ptr_eq(p, buf + 8);
  ck_assert(ret == DBL_MIN);
}
END_TEST

START_TEST(read_double_le_negative_min)
{
  uint8_t buf[8] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xEF, 0xFF};
  uint8_t *p = buf;
  double ret = read_double_le(&p);
  ck_assert_ptr_eq(p, buf + 8);
  ck_assert(ret == -DBL_MAX);
}
END_TEST


START_TEST(read_string)
{
  const char *test_string = "ABCDEFGHIJK4567890qwerty";

  size_t buf_size = strlen(test_string) + 1;
  uint8_t *buf = malloc(buf_size);
  if (buf == NULL) {
    ck_abort_msg("malloc failed");
  }
  memcpy(buf, test_string, strlen(test_string));
  buf[buf_size - 1] = '\0';

  const uint8_t *p = buf;
  char *output = NULL;
  size_t size = buf_size;

  size_t ret = read_string_len(&output, &p, &size);
  ck_assert_int_eq(ret, buf_size);
  ck_assert_str_eq(output, test_string);
  ck_assert_ptr_eq(p, buf + buf_size);
  ck_assert_uint_eq(size, 0);

  free(output);
  free(buf);
}
END_TEST

START_TEST(read_string_twice)
{
  const char *test_string1 = "123456";
  const char *test_string2 = "abcdefghijklmno";

  size_t buf_size = strlen(test_string1) + 1 + strlen(test_string2) + 1;
  uint8_t *buf = malloc(buf_size);
  if (buf == NULL) {
    ck_abort_msg("malloc failed");
  }
  memcpy(buf, test_string1, strlen(test_string1));
  buf[strlen(test_string1)] = '\0';

  memcpy(buf + strlen(test_string1) + 1, test_string2, strlen(test_string2));
  buf[strlen(test_string1) + 1 + strlen(test_string2)] = '\0';

  const uint8_t *p = buf;
  char *output = NULL;
  size_t size = buf_size;

  size_t ret = read_string_len(&output, &p, &size);
  ck_assert_int_eq(ret, (strlen(test_string1) + 1));
  ck_assert_str_eq(output, test_string1);
  ck_assert_ptr_eq(p, buf + (strlen(test_string1) + 1));
  ck_assert_uint_eq(size, buf_size - (strlen(test_string1) + 1));
  free(output);

  ret = read_string_len(&output, &p, &size);
  ck_assert_int_eq(ret, (strlen(test_string2) + 1));
  ck_assert_str_eq(output, test_string2);
  ck_assert_ptr_eq(p, buf + buf_size);
  ck_assert_uint_eq(size, 0);
  free(output);

  free(buf);
}
END_TEST

START_TEST(read_string_overrun)
{
  const char *test_string = "ABCDE";

  size_t buf_size = strlen(test_string); // no '\0' at the end
  uint8_t *buf = malloc(buf_size);
  if (buf == NULL) {
    ck_abort_msg("malloc failed");
  }
  memcpy(buf, test_string, buf_size);

  const uint8_t *p = buf;
  char *output = NULL;
  size_t size = buf_size;

  size_t ret = read_string_len(&output, &p, &size);
  ck_assert_int_eq(ret, 0);
  ck_assert_ptr_eq(p, buf);
  ck_assert_uint_eq(size, buf_size);

  free(buf);
}
END_TEST


Suite *suite(void) {
  Suite *s = suite_create("bson_util_test");

  TCase *tc = tcase_create("read_bytes");
  tcase_add_test(tc, read_int32_le_zero);
  tcase_add_test(tc, read_int32_le_positive);
  tcase_add_test(tc, read_int32_le_negative);
  tcase_add_test(tc, read_int32_le_positive_max);
  tcase_add_test(tc, read_int32_le_negative_max);
  tcase_add_test(tc, read_int32_le_negative_min);

  tcase_add_test(tc, read_int64_le_zero);
  tcase_add_test(tc, read_int64_le_positive);
  tcase_add_test(tc, read_int64_le_negative);
  tcase_add_test(tc, read_int64_le_positive_max);
  tcase_add_test(tc, read_int64_le_negative_max);
  tcase_add_test(tc, read_int64_le_negative_min);

  tcase_add_test(tc, read_double_le_zero);
  tcase_add_test(tc, read_double_le_positive);
  tcase_add_test(tc, read_double_le_negative);
  tcase_add_test(tc, read_double_le_positive_max);
  tcase_add_test(tc, read_double_le_positive_min);
  tcase_add_test(tc, read_double_le_negative_min);

  tcase_add_test(tc, read_string);
  tcase_add_test(tc, read_string_twice);
  tcase_add_test(tc, read_string_overrun);

  suite_add_tcase(s, tc);
  return s;
}

int main(void) {
  int failed_num = 0;
  Suite *s = suite();
  SRunner *sr = srunner_create(s);
  srunner_set_fork_status(sr, CK_NOFORK);

  srunner_run_all(sr, CK_NORMAL);

  failed_num = srunner_ntests_failed(sr);
  srunner_free(sr);

  return failed_num == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
}
