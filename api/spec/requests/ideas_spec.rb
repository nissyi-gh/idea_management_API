# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Ideas', type: :request do
  describe 'アイデア登録API' do
    context 'リクエストのcategory_nameがcategoriesテーブルのnameに存在する場合' do
      before do
        @exist_category = create(:category, :task)
      end

      it 'ideasテーブルに登録できて、ステータスコード201を返す' do
        post api_v1_ideas_path, params: {
          category_name: @exist_category.name,
          body: build(:idea, :doing_task)
        }
        expect(response).to have_http_status(201)
      end

      it 'ideasテーブルに登録できて、ideasテーブルの件数が増える' do
        expect do
          post api_v1_ideas_path, params: {
            category_name: @exist_category.name,
            body: build(:idea, :doing_task)
          }
        end.to change { Idea.count }.from(0).to(1)
      end

      it 'ideasテーブルに登録できて、Categoryの件数は変わらない' do
        expect do
          post api_v1_ideas_path, params: {
            category_name: @exist_category.name,
            body: build(:idea, :doing_task)
          }
        end.to change { Category.count }.by(0)
      end
    end

    context 'リクエストのcategory_nameがcategoriesテーブルのnameに存在しない場合' do
      before do
        @exist_category = create(:category, :task)
        @new_category = build(:category, :application)
      end

      it 'ideasテーブルに登録できて、ステータスコード201を返す' do
        post api_v1_ideas_path, params: {
          category_name: @new_category.name,
          body: build(:idea, :doing_task)
        }
        expect(response).to have_http_status(201)
      end

      it 'ideasテーブルに登録できて、ideasテーブルの件数が増える' do
        expect do
          post api_v1_ideas_path, params: {
            category_name: @new_category.name,
            body: build(:idea, :doing_task)
          }
        end.to change { Idea.count }.from(0).to(1)
      end

      it 'ideasテーブルに登録でき、Categoryの件数も増加する' do
        expect do
          post api_v1_ideas_path, params: {
            category_name: @new_category.name,
            body: build(:idea, :doing_task)
          }
        end.to change { Category.count }.from(1).to(2)
      end
    end
  end

  describe 'アイデア取得API' do
    context 'リクエストのcategory_nameが指定されている場合' do
      before do
        @task_category = create(:category, :task)
        @task_idea = create(:idea, :doing_task, category_id: @task_category.id)

        @app_category = create(:category, :application)
        @app_idea = create(:idea, :create_application, category_id: @app_category.id)

        @expect_return_task_idea_json = {
          id: @task_idea.id,
          category: @task_category.name,
          body: @task_idea.body,
          created_at: Time.parse(@task_idea.created_at.to_s(:db)).to_i
        }.to_json

        @expect_return_app_idea_json = {
          id: @task_idea.id,
          category: @task_category.name,
          body: @task_idea.body,
          created_at: Time.parse(@task_idea.created_at.to_s(:db)).to_i
        }.to_json
      end

      it '登録されたcategoryなら、該当するcategoryのidea一覧を返却する' do
        # task_ideaの取得を試みる
        get api_v1_ideas_path, params: {
          category_name: @task_category.name
        }
        expect(JSON.parse(response.body)).to eq(
          [JSON.parse(@expect_return_task_idea_json)]
        )
      end

      it '登録されていないcategoryなら、404を返す' do
        get api_v1_ideas_path, params: {
          category_name: build(:category, :meeting)
        }
        expect(response).to have_http_status(404)
      end
    end

    context 'リクエストのcategory_nameが指定されていない場合' do
      before do
        @task_category = create(:category, :task)
        @task_idea = create(:idea, :doing_task, category_id: @task_category.id)

        @app_category = create(:category, :application)
        @app_idea = create(:idea, :create_application, category_id: @app_category.id)

        @expect_return_task_idea_json = {
          id: @task_idea.id,
          category: @task_category.name,
          body: @task_idea.body,
          created_at: Time.parse(@task_idea.created_at.to_s(:db)).to_i
        }.to_json

        @expect_return_app_idea_json = {
          id: @app_idea.id,
          category: @app_category.name,
          body: @app_idea.body,
          created_at: Time.parse(@app_idea.created_at.to_s(:db)).to_i
        }.to_json
      end

      it 'すべてのideasを返却する' do
        get api_v1_ideas_path

        expect(JSON.parse(response.body)).to eq(
          [
            JSON.parse(@expect_return_task_idea_json),
            JSON.parse(@expect_return_app_idea_json)
          ]
        )
      end
    end
  end
end
