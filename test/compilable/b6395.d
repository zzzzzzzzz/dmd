// REQUIRED_ARGS: -c -Icompilable/extra-files

// 6395

import c6395;

int regex(string pattern)
{
  return 0;
}

bool match(string r)
{
  return true;
}

void applyNoRemoveRegex()
{
  void scan(string[] noRemoveStr, string e)
  {
    auto a = find!((a){return match(e);})(map!regex(noRemoveStr));
  }
}

