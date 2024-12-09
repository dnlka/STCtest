#ifndef THREADSAFEQUEUE_H
#define THREADSAFEQUEUE_H

#include <queue>
#include <mutex>
#include <optional>

template <typename T>
class ThreadSafeQueue
{
public:
    void enqueue(const T& item){

        std::lock_guard<std::mutex> lock(mutex);
        queue.push(item);
    }


    void enqueue(T&& item) {

        std::lock_guard<std::mutex> lock(mutex);
        queue.push(std::move(item));
    }


    std::optional<T> dequeue() {

        std::unique_lock<std::mutex> lock(mutex);

        if (queue.empty())
            return std::nullopt;

        T item = std::move(queue.front());
        queue.pop();
        return item;
    }


    bool empty() const {

        std::lock_guard<std::mutex> lock(mutex);
        return queue.empty();
    }


    size_t size() const {

        std::lock_guard<std::mutex> lock(mutex);
        return queue.size();
    }

private:
    mutable std::mutex mutex;
    std::queue<T> queue;
};

#endif // THREADSAFEQUEUE_H
