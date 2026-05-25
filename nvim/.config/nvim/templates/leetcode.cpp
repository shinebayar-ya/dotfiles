#include <bits/stdc++.h>
using namespace std;
using i64 = long long;

struct ListNode {
  int val;
  ListNode *next;
  ListNode() : val(0), next(nullptr) {}
  ListNode(int x) : val(x), next(nullptr) {}
  ListNode(int x, ListNode *next) : val(x), next(next) {}
};

struct TreeNode {
  int val;
  TreeNode *left;
  TreeNode *right;
  TreeNode() : val(0), left(nullptr), right(nullptr) {}
  TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
  TreeNode(int x, TreeNode *l, TreeNode *r) : val(x), left(l), right(r) {}
};

class Solution {
public:

};

ListNode* buildList(initializer_list<int> xs) {
  ListNode dummy(0);
  ListNode *tail = &dummy;
  for (int x : xs) {
    tail->next = new ListNode(x);
    tail = tail->next;
  }
  return dummy.next;
}

void printList(ListNode *head) {
  for (ListNode *cur = head; cur != nullptr; cur = cur->next) {
    cout << cur->val;
    if (cur->next) cout << ',';
  }
  cout << '\n';
}

int main() {
  ios::sync_with_stdio(false);
  cin.tie(nullptr);

  Solution sol;
  // example:
  // ListNode *l1 = buildList({2,4,3});
  // ListNode *l2 = buildList({5,6,4});
  // printList(sol.addTwoNumbers(l1, l2));

  return 0;
}
