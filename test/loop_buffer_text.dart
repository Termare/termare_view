class LoopBuffer {
  LoopBuffer(int k) {
    elem = List.filled(k, 0);
    front = 0;
    rear = 0;
  }
  late int front; //队列头
  late int rear; //队列尾
  late List<int> elem; //数组

  bool enQueue(int value) {
    if (isFull()) {
      front = (front + 1) % elem.length;
    }
    elem[rear] = value;
    rear = (rear + 1) % elem.length;
    return true;
  }

  //队尾下标加上1在%
  bool isFull() {
    if ((rear + 1) % elem.length == front) {
      return true;
    }
    return false;
  }

  bool isEmpty() {
    return rear == front;
  }

  bool deQueue(int value) {
    if (isEmpty()) {
      return false;
    }
    elem[front] = value;
    front = (front + 1) % elem.length;
    return true;
  }

  int getFront() {
    if (isEmpty()) {
      throw '队列为空';
    }
    return elem[front];
  }

  int getRear() {
    if (isEmpty()) {
      throw '队列为空';
    }
    final int index = rear == 0 ? elem.length - 1 : rear - 1;
    return elem[index];
  }
}

void main() {
  LoopBuffer buffer = LoopBuffer(10);
  print(buffer.front);
  print(buffer.rear);
  for (int i = 0; i < 9; i++) {
    buffer.enQueue(i);
  }
  buffer.enQueue(1);
  buffer.enQueue(1);
  buffer.enQueue(1);
  buffer.enQueue(1);
  buffer.enQueue(2);
  print(buffer.elem);
  print(buffer.front);
  print(buffer.rear);
}
